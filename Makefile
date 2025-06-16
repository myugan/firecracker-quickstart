.PHONY: install build run start

export ARCH=x86_64

install:
	./install.sh

build:
	docker build -t rootfs .
	docker create --name extract rootfs
	docker export extract -o ./rootfs.tar
	docker rm -f extract

	fallocate -l 5G ./rootfs.img
	mkfs.ext4 ./rootfs.img
	TMP=$$(mktemp -d)
	mount -o loop ./rootfs.img $$TMP
	tar -xvf ./rootfs.tar -C $$TMP
	umount $$TMP

run:
	rm -rf /tmp/firecracker.socket || true
	firecracker --api-sock /tmp/firecracker.socket

start:
	./configure.sh

stop:
	kill -9 $$(pgrep firecracker) || true
	rm -rf /tmp/firecracker.socket || true