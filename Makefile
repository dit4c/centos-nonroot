all: build/rootfs/sig-cloud-instance-images

build:
	mkdir -p build

build/proot: build
	curl -# -L http://portable.proot.me/proot-x86_64 > build/proot
	chmod +x build/proot

build/rootfs: build/proot
	mkdir -p build/rootfs
	curl -# -L "https://github.com/gliderlabs/docker-alpine/blob/f2e97b32d9d5a3378ceddf33d30623106517a3a8/versions/library-3.2/rootfs.tar.gz?raw=true" | tar xz -C build/rootfs

build/rootfs/sig-cloud-instance-images: build/rootfs
	build/proot -S build/rootfs \
		-b build/proot:/usr/sbin/proot \
		-b build.sh:/build.sh \
		-b init_alpine.sh:/init_alpine.sh \
		/init_alpine.sh

clean:
	rm -rf build
