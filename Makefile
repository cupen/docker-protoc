
protoc_version:=3.17.3
protoc_url:=http://172.27.155.227:8000/protoc-$(protoc_version)-linux-x86_64.zip

test-in-devenv:
	docker build . \
		--build-arg protoc_url=$(protoc_url) \
		--build-arg goproxy=https://goproxy.cn,direct \
		--tag cupen/protoc-test:$(protoc_version)

