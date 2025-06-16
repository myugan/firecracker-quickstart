#!/bin/bash

API_SOCKET="/tmp/firecracker.socket"

KERNEL="./vmlinux-5.10.209"
KERNEL_BOOT_ARGS="console=ttyS0 reboot=k panic=1 pci=off ip=${FC_IP}::${GATEWAY_IP}:${MASK_LONG}::eth0:off"
ROOTFS="./rootfs.img"

TAP_DEV="tap0"
GATEWAY_IP="172.16.10.1"
FC_IP="172.16.10.100"
MASK_LONG="255.255.255.0"

function curl_put() {
    curl -s -X PUT --unix-socket "${API_SOCKET}" -i \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        --data "$1" \
        "http://localhost/$2"
}

if [ -f "${API_SOCKET}" ]; then
    echo "Firecracker socket already exists"
    exit 1
fi

echo "Setting up TAP device"
if ! ip tuntap show | grep -q "${TAP_DEV}"; then
    ip tuntap add dev $TAP_DEV mode tap
    ip addr add $GATEWAY_IP/24 dev $TAP_DEV
    ip link set $TAP_DEV up
fi

if [ ! -f "${KERNEL}" ]; then
    echo "Kernel not found: ${KERNEL}"
    exit 1
fi

if [ ! -f "${ROOTFS}" ]; then
    echo "Rootfs not found: ${ROOTFS}"
    exit 1
fi

echo "Setting up boot source"
curl_put "{\"kernel_image_path\": \"${KERNEL}\", \"boot_args\": \"${KERNEL_BOOT_ARGS}\"}" "boot-source"

echo "Setting up rootfs"
curl_put "{\"drive_id\": \"rootfs\", \"path_on_host\": \"${ROOTFS}\", \"is_root_device\": true, \"is_read_only\": false}" "drives/rootfs"

echo "Setting up network interface"
curl_put "{\"iface_id\": \"eth0\", \"host_dev_name\": \"$TAP_DEV\"}" "network-interfaces/eth0"

echo "Setting up machine config"
curl_put "{\"vcpu_count\": 1, \"mem_size_mib\": 512}" "machine-config"

echo "Starting microVM"
curl_put "{\"action_type\": \"InstanceStart\"}" "actions"