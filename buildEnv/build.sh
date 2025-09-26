#!/bin/bash
#
# build.sh
#
# Creates the build environment required to re-build the images for my FriendlyARM NanoPi R4S client devices.
#

### Prerequisites for buildroot
# Modernized set for Ubuntu 24.04 that has Python 3.12 without python3-distutils from https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem#debianubuntumint
sudo apt update
sudo apt install build-essential clang flex bison g++ gawk gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig unzip zlib1g-dev file wget

RELEASE='https://downloads.openwrt.org/releases/24.10.3/targets/rockchip/armv8/openwrt-imagebuilder-24.10.3-rockchip-armv8.Linux-x86_64.tar.zst'
DIR='openwrt-imagebuilder-24.10.3-rockchip-armv8.Linux-x86_64'
PROFILE='friendlyarm_nanopi-r4s'


### Get imagebuilder and cd there
echo "$RELEASE"
curl -L  "$RELEASE" | tar --zstd -xf -

cd "$DIR" || exit

NAS='kmod-usb-storage kmod-usb-storage-uas e2fsprogs kmod-fs-ext4 kmod-fs-f2fs ntfs-3g kmod-fs-exfat kmod-fs-hfs kmod-fs-hfsplus luci-app-samba4 usbutils block-mount fdisk'

### make!
make clean
make image PROFILE="$PROFILE" PACKAGES="-ppp -ppp-mod-pppoe -ip6tables -odhcp6c -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only luci nano luci-ssl owut $NAS" EXTRA_IMAGE_NAME="aliicex" DISABLED_SERVICES="dnsmasq firewall"
