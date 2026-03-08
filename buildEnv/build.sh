#!/bin/bash
#
# build.sh
#
# Creates the build environment required to re-build the images for my FriendlyARM NanoPi R4S client devices.
#

### Prerequisites for buildroot
sudo apt update
sudo apt install build-essential file libncurses-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python3 python3-setuptools

RELEASE='https://downloads.openwrt.org/releases/25.12.0/targets/rockchip/armv8/openwrt-imagebuilder-25.12.0-rockchip-armv8.Linux-x86_64.tar.zst'
DIR='openwrt-imagebuilder-25.12.0-rockchip-armv8.Linux-x86_64'
PROFILE='friendlyarm_nanopi-r4s'


### Get imagebuilder and cd there
echo "$RELEASE"
curl -L  "$RELEASE" | tar --zstd -xf -

cd "$DIR" || exit

NAS='kmod-usb-storage kmod-usb-storage-uas e2fsprogs kmod-fs-ext4 kmod-fs-f2fs ntfs-3g kmod-fs-exfat kmod-fs-hfs kmod-fs-hfsplus luci-app-samba4 luci-app-hd-idle usbutils block-mount fdisk'

### make!
make clean
make image PROFILE="$PROFILE" PACKAGES="-ppp -ppp-mod-pppoe -ip6tables -odhcp6c -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only luci nano luci-ssl owut $NAS" EXTRA_IMAGE_NAME="aliicex" DISABLED_SERVICES="dnsmasq firewall"
