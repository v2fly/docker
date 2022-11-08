# Docker Fly

docker build repo for v2fly

https://hub.docker.com/r/v2fly/v2fly-core

## Usage

```bash
docker run --rm v2fly/v2fly-core help

docker run --name v2ray v2fly/v2fly-core $v2ray_args (help, eun etc...)

docker run -d --name v2ray -v /path/to/config.json:/etc/v2fly/config.json -p 10086:10086 v2fly/v2fly-core run -c /etc/v2fly/config.json 
```