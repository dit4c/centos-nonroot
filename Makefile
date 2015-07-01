all: build

docker: build
	bash -c "cd build/sig-cloud-instance-images/docker && docker build -t centos-nonroot ."

build:
	mkdir -p ./build
	docker run -ti --rm \
		--privileged \
		-v `pwd`/init_alpine.sh:/init_alpine.sh \
		-v `pwd`/build.sh:/build.sh \
		-v `pwd`/build/:/build/ \
		-e CHOWN_TO=`id -u` \
		alpine:3.2 /init_alpine.sh

clean:
	rm -rf build
