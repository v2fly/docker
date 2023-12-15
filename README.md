# Docker Fly

docker build repo for v2fly

https://hub.docker.com/r/v2fly/v2fly-core

## Usage

```bash
docker run --rm v2fly/v2fly-core help

docker run --name v2ray v2fly/v2fly-core $v2ray_args (help, eun etc...)

docker run -d --name v2ray -v /path/to/config.json:/etc/v2ray/config.json -p 10086:10086 v2fly/v2fly-core run -c /etc/v2ray/config.json 

# If you want to use v5 format config
docker run -d --name v2ray -v /path/to/config.json:/etc/v2ray/config.json -p 10086:10086 v2fly/v2fly-core run -c /etc/v2ray/config.json -format jsonv5
```

## 使用TPROXY透明代理的额外说明

  - 需要添加容器启动参数 `--privileged` 使用特权模式启动
  
  - 使用容器macvlan功能，为容器分配一个独占的主网络IP地址

  - macvlan默认不支持dns，启动容器时挂载宿主机 `-v /etc/resolv.conf:/etc/resolv.conf` 文件保证容器内域名可以正常解析

  - 为宿主机的主网卡开启混杂模式

  - 如果容器以host网络方式启动，则不需要以上几步操作，直接就可以用（不推荐host方式，还是推荐容器完全隔离模式启动）
 
  - 启动容器使用 `--entrypoint="/usr/bin/v2ray-tproxy"` 覆盖默认的 entrypoint
