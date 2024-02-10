# Docker Fly

docker build repo for v2fly

https://hub.docker.com/r/implementsio/v2fly

## Usage

```bash
docker run --rm implementsio/v2fly help

docker run --name v2ray implementsio/v2fly $v2ray_args (help, eun etc...)

docker run -d --name v2ray -v /path/to/config.json:/etc/v2ray/config.json -p 10086:10086 implementsio/v2fly run -c /etc/v2ray/config.json 

# If you want to use v5 format config
docker run -d --name v2ray -v /path/to/config.json:/etc/v2ray/config.json -p 10086:10086 implementsio/v2fly run -c /etc/v2ray/config.json -format jsonv5
```
