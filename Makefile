protoc_version:=3.19.4
protoc_url:=http://127.0.0.1:8000/protoc-$(protoc_version)-linux-x86_64.zip

build-in-devenv:
	docker build . \
		--network host \
		--build-arg protoc_url=$(protoc_url) \
		--build-arg goproxy=https://goproxy.cn,direct \
		--tag cupen/protoc:$(protoc_version)
