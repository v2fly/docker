#!/bin/sh


setupTProxy() { 

    local docker_network="$(ip -o addr show dev eth0 | awk '$3 == "inet" {print $4}')"
    local default_gateway=$(ip -4 route | grep 'default via' | awk '{print $3}')
    local dokodemo_port=12345

    if [[ $DOKODEMO_DOOR_PORT ]]; then
        dokodemo_port=$DOKODEMO_DOOR_PORT
    fi

    echo "
--- Setting up the gateway iptables rules ----
        dokodemo-door port: ${dokodemo_port}
        Bypassed subnets: ${docker_network}, ${BYPASS_SUBNETS}
        Default gateway: ${default_gateway}
Pay attention: This gateway handles the TCP and UDP requests. The Dokodemo-door doesn't support ICMP packets!"

    # Reference: https://guide.v2fly.org/app/tproxy.html#%E8%AE%BE%E7%BD%AE%E7%BD%91%E5%85%B3
    # Set policy routing
    ip rule add fwmark 1 table 100 
    ip route add local 0.0.0.0/0 dev lo table 100
    # Proxy LAN device
    iptables -t mangle -N V2RAY
    iptables -t mangle -A V2RAY -d 127.0.0.1/24 -j RETURN
    iptables -t mangle -A V2RAY -d 224.0.0.0/4 -j RETURN 
    iptables -t mangle -A V2RAY -d 255.255.255.255/32 -j RETURN 
    iptables -t mangle -A V2RAY -d ${docker_network} -p tcp -j RETURN # Directly connect to the LAN to avoid SSH that cannot connect to the gateway when V2Ray cannot be started. If you configure other network segments (such as 10.x.x.x, etc.), modify it to your own
    iptables -t mangle -A V2RAY -d ${docker_network} -p udp ! --dport 53 -j RETURN # Directly connected to the LAN, except port 53 (because V2Ray's DNS is used)
    if [[ $BYPASS_SUBNETS ]]; then
        for subnet in ${BYPASS_SUBNETS//,/ }; do
            iptables -t mangle -A V2RAY -d "$subnet" -p tcp -j RETURN 
            iptables -t mangle -A V2RAY -d "$subnet" -p udp ! --dport 53 -j RETURN 
        done
    fi
    iptables -t mangle -A V2RAY -j RETURN -m mark --mark 0xff    # Directly connect to the traffic whose SO_MARK is 0xff (0xff is a hexadecimal number, which is equivalent to 255 in the above V2Ray configuration). The purpose of this rule is to solve the problem that v2ray takes up a lot of CPU（https://github.com/v2ray/v2ray-core/issues/2621）
    iptables -t mangle -A V2RAY -p udp -j TPROXY --on-ip 127.0.0.1 --on-port ${dokodemo_port} --tproxy-mark 1 # Mark UDP as 1 and forward to port 12345
    iptables -t mangle -A V2RAY -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port ${dokodemo_port} --tproxy-mark 1 # Mark the TCP with 1 and forward it to port 12345
    iptables -t mangle -A PREROUTING -j V2RAY # application rules

    # proxy gateway native
    iptables -t mangle -N V2RAY_MASK 
    iptables -t mangle -A V2RAY_MASK -d 224.0.0.0/4 -j RETURN 
    iptables -t mangle -A V2RAY_MASK -d 255.255.255.255/32 -j RETURN 
    iptables -t mangle -A V2RAY_MASK -d ${docker_network} -p tcp -j RETURN # Direct LAN
    iptables -t mangle -A V2RAY_MASK -d ${docker_network} -p udp ! --dport 53 -j RETURN # Directly connected to LAN, except port 53 (because V2Ray's DNS is used)
    if [[ $BYPASS_SUBNETS ]]; then
        for subnet in ${BYPASS_SUBNETS//,/ }; do
            iptables -t mangle -A V2RAY_MASK -d "$subnet" -p tcp -j RETURN # Direct LAN
            iptables -t mangle -A V2RAY_MASK -d "$subnet" -p udp ! --dport 53 -j RETURN # Directly connected to LAN, except port 53 (because V2Ray's DNS is used)
        done
    fi
    iptables -t mangle -A V2RAY_MASK -j RETURN -m mark --mark 0xff    # Directly connect to traffic whose SO_MARK is 0xff (0xff is a hexadecimal number, which is equivalent to 255 in the above V2Ray configuration). The purpose of this rule is to avoid the loopback problem of proxy local (gateway) traffic
    iptables -t mangle -A V2RAY_MASK -p udp -j MARK --set-mark 1   # Mark UDP, reroute
    iptables -t mangle -A V2RAY_MASK -p tcp -j MARK --set-mark 1   # Mark TCP, reroute
    iptables -t mangle -A OUTPUT -j V2RAY_MASK # application rules

    # Create a new DIVERT rule to prevent existing connected packets from passing through TPROXY twice, theoretically, there is a certain performance improvement
    iptables -t mangle -N DIVERT
    iptables -t mangle -A DIVERT -j MARK --set-mark 1
    iptables -t mangle -A DIVERT -j ACCEPT
    iptables -t mangle -I PREROUTING -p tcp -m socket -j DIVERT
}


if [[ "$TPROXY" = "true" ]]; then
    setupTProxy &
fi

/usr/bin/v2ray "$@"