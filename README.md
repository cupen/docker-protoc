# Usage
```
docker build .
```
or if you want use `GOPROXY`
```
docker build -t yourname:latest --build-arg protoc_version=3.17.3 --build-arg=goproxy=https://goproxy.cn,direct .
```

That's all.