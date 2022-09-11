#!/bin/bash
#
# build.sh
#
# Creates the build environment required to re-build my image for the FriendlyARM NanoPi R4S and the PC Engines apu2 platform
#

### Prerequisites for buildroot
sudo apt update
sudo apt install build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python

# https://openwrt.org/toh/pcengines/apu2
PACKAGES_EXTRA='kmod-leds-gpio kmod-crypto-hw-ccp kmod-gpio-nct5104d kmod-gpio-button-hotplug kmod-sp5100-tco kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb3 kmod-sound-core kmod-pcspkr amd64-microcode flashrom irqbalance fstrim'

# https://openwrt.org/docs/guide-user/network/wan/smartphone.usb.tethering
PACKAGES_TETHERING='kmod-usb-net-rndis kmod-usb-net-cdc-ncm kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-eem kmod-usb-net-cdc-ether kmod-usb-net-cdc-subset kmod-nls-base kmod-usb-core kmod-usb-net kmod-usb2 kmod-usb-net-ipheth usbmuxd libimobiledevice usbutils'

PS3='Please select your preferred OpenWRT target: '
options=("r4s" "apu2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "r4s")
            echo "Building image for NanoPi R4S"
            RELEASE='https://downloads.openwrt.org/releases/22.03.0/targets/rockchip/armv8/openwrt-imagebuilder-22.03.0-rockchip-armv8.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-22.03.0-rockchip-armv8.Linux-x86_64'
            PROFILE='friendlyarm_nanopi-r4s'
            unset PACKAGES_EXTRA
            break
            ;;
        "apu2")
            echo "Building image for PC Engines apu2 platform"
            RELEASE='https://downloads.openwrt.org/releases/22.03.0/targets/x86/64/openwrt-imagebuilder-22.03.0-x86-64.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-22.03.0-x86-64.Linux-x86_64'
            PROFILE='generic'
            break
          ;;
        "Quit")
            exit 1
            ;;
        *) echo "invalid option $REPLY"
        	;;
    esac
done

### Get imagebuilder and cd there
echo "$RELEASE"
curl -L  "$RELEASE" | unxz | tar -xf -

cd "$DIR" || exit

### files dir (outside main directory to protect from make distclean)
mkdir -p files/etc/config
cp ../files/* files/etc/config/

### add repo to repositories.conf
sed -i '/check_signature/d' repositories.conf
sed -i '/stangri_repo/d' repositories.conf
! grep -q 'stangri_repo' repositories.conf && sed -i '2 i\src/gz stangri_repo repo.openwrt.melmac.net' repositories.conf

### banIP is marked as broken after 21.02.x (https://forum.openwrt.org/t/banip-support-thread/16985/751)
BANIP='banip luci-app-banip'
unset BANIP

### make!
make clean
make image PROFILE="$PROFILE" PACKAGES="luci luci-ssl luci-theme-openwrt-2020 -dnsmasq dnsmasq-full ipset libnettle8 libnetfilter-conntrack3 kmod-ipt-nat6 luci-app-sqm sqm-scripts sqm-scripts-extra kmod-wireguard luci-app-wireguard luci-proto-wireguard wireguard-tools qrencode stubby unbound-daemon luci-app-unbound https-dns-proxy luci-app-https-dns-proxy watchcat luci-app-watchcat pbr luci-app-pbr curl wget tcpdump etherwake luci-app-wol 6in4 6to4 6rd usb-modeswitch comgt-ncm kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan luci-proto-ncm luci-proto-3g avahi-dbus-daemon $BANIP avahi-utils smcroute zerotier ntpclient $PACKAGES_EXTRA $PACKAGES_TETHERING" EXTRA_IMAGE_NAME="byteandnibble" FILES=files/ DISABLED_SERVICES="stubby unbound pbr avahi-daemon etherwake https-dns-proxy zerotier"
