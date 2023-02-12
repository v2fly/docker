# Docker Fly

docker build repo for v2fly

https://hub.docker.com/r/v2fly/v2fly-core

## Usage

```bash
docker run --rm v2fly/v2fly-core help

docker run --name v2ray v2fly/v2fly-core $v2ray_args (help, eun etc...)

docker run -d --name v2ray -v /path/to/config.json:/etc/v2fly/config.json -p 10086:10086 v2fly/v2fly-core run -c /etc/v2fly/config.json 
```
---
# Gateway mode
You can use v2ray as a network gateway for serving a proxied network to another container or other devices in the network. 

For running the container in gateway mode you need to make some changes in you v2ray config file.

1. Add an additional inbound with the dokodemo-door protocol for listening on the 12345 port (like example)
2. Add a mark of 255 to all the outbounds

### Example of config file for gateway mode
```json
{
  "inbounds": [
    {
      "port": 1080, 
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      },
      "settings": {
        "auth": "noauth"
      }
    }, 
    {
      "tag":"transparent",
      "port": 12345,
      "protocol": "dokodemo-door",
      "settings": {
        "network": "tcp,udp",
        "followRedirect": true
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "streamSettings": {  // it's necessary
        "sockopt": {
          "tproxy": "tproxy",
          "mark":255
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy-1",
      "protocol": "vmess",
      "settings": {
        "vnext": [
          ...
        ]
      },
      "streamSettings": {  
        "sockopt": {        // You should add these settings for all of the outbounds
          "mark": 255
        }
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIP"
      },
      "streamSettings": {
        "sockopt": {        // Even for freedom 
          "mark": 255
        }
      }      
    },
    {
      "tag": "block",
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      }
    },
    {
      "tag": "dns-out",
      "protocol": "dns",
      "streamSettings": {
        "sockopt": {
          "mark": 255
        }
      }  
    }
  ],
  "dns": {
    "servers": [
      ...
    ]
  },
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "transparent"
        ],
        "port": 53,
        "network": "udp",
        "outboundTag": "dns-out" 
      },    
      { // Directly connect to port 123 UDP traffic (NTP protocol)
        "type": "field",
        "inboundTag": [
          "transparent"
        ],
        "port": 123,
        "network": "udp",
        "outboundTag": "direct" 
      },    
      ...
    ]
  }
}

```

Please read [this topic](https://guide.v2fly.org/app/tproxy.html) for more details.


### Example of a home network gateway with docker compose
```yaml
version: '3.4'
services:
  v2ray:
    image: v2fly/v2fly-core
    cap_add:
      - NET_ADMIN # Required in gateway mode
    volumes:
      - ./testConfig.json:/etc/v2ray/config.json
    environment:
      - TPROXY=true # Active the gateway mode
    command: ['run','-c','/etc/v2ray/config.json']
    networks:
      vlan:
        ipv4_address: 192.168.1.254 # The IP address of this container which other devices can use this IP as a gateway.

networks:
  vlan:
    driver: macvlan
    driver_opts:
      parent: ens3 # The ethernet adaptor in the host system 
    ipam:
      driver: default
      config:
        - subnet: 192.168.1.0/24  # Home network subnet
          gateway: 192.168.1.1 # Home network gateway (your router ip)

```


###  Example of a gateway for other containers with docker compose
```yaml
version: '3.4'
services:
  v2ray:
    image: v2fly/v2fly-core
    cap_add:
      - NET_ADMIN # Required in gateway mode
    volumes:
      - ./testConfig.json:/etc/v2ray/config.json
    environment:
      - TPROXY=true # Active the gateway mode
    command: ['run','-c','/etc/v2ray/config.json']
    networks:
      bridgenetwork:
        ipv4_address: 192.168.30.1

  test-conatiner:
    image: weibeld/ubuntu-networking
    depends_on:
      - v2ray
    stdin_open: true
    privileged: true
    networks:
      bridgenetwork:

    command: >          # Adding the v2ray container IP as a default gateway
      sh -c "ip route del default &&
      ip route add default via 192.168.30.1 &&
      tail -f /dev/null"
networks:
  bridgenetwork:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: "192.168.30.0/24"
          gateway: "192.168.30.254"
```