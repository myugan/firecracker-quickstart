#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -yq ca-certificates curl net-tools python3-pip python3-nftables python3-venv

echo "Installing Docker"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin

echo "Installing Firecracker"
VERSION="1.12.0"

wget -q https://github.com/firecracker-microvm/firecracker/releases/download/v${VERSION}/firecracker-v${VERSION}-x86_64.tgz
tar -xzvf firecracker-v${VERSION}-x86_64.tgz
mv release-v${VERSION}-x86_64/firecracker-v${VERSION}-x86_64 /usr/local/bin/firecracker
rm -rf release-v${VERSION}-x86_64

echo "Enabling port forwarding"
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -P FORWARD ACCEPT

echo "Downloading kernel"
wget -q https://s3.amazonaws.com/spec.ccfc.min/firecracker-ci/4360-tmp-artifacts/x86_64/vmlinux-5.10.209
wget -q https://s3.amazonaws.com/spec.ccfc.min/firecracker-ci/4360-tmp-artifacts/x86_64/vmlinux-6.1.76

echo "Firecracker version: ${VERSION}"
echo "Kernel available: vmlinux-5.10.209, vmlinux-6.1.76"
