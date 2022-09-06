#!/bin/bash
#
# apu2BuildRoot.sh
#
# Creates the build environment required to re-build my image for APU2 boards with at least 2 NICs
#

### Prerequisites for buildroot
sudo apt update
sudo apt install build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python


PS3='Please select your preferred OpenWRT release: '
options=("Snapshot" "22.03.0" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Snapshot")
            echo "Using OpenWrt Snapshot"
            VERSION='snapshot'
            RELEASE='https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-imagebuilder-x86-64.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-x86-64.Linux-x86_64'
            break
            ;;
        "22.03.0")
            echo "Using OpenWrt 22.03.0"
            VERSION='22.03.0'
            RELEASE='https://downloads.openwrt.org/releases/22.03.0/targets/x86/64/openwrt-imagebuilder-22.03.0-x86-64.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-22.03.0-x86-64.Linux-x86_64'
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

### make!
make clean
make image PACKAGES="luci luci-ssl luci-theme-openwrt-2020 -dnsmasq dnsmasq-full ipset libnettle8 libnetfilter-conntrack3 kmod-gpio-button-hotplug kmod-crypto-hw-ccp kmod-leds-gpio kmod-usb-ohci kmod-usb2 kmod-usb3 kmod-gpio-nct5104d kmod-pcspkr kmod-usb-core kmod-sound-core kmod-ipt-nat6 fstrim irqbalance amd64-microcode flashrom luci-app-sqm luci-app-wireguard luci-proto-wireguard qrencode stubby unbound-daemon luci-app-unbound https-dns-proxy luci-app-https-dns-proxy watchcat luci-app-watchcat pbr luci-app-pbr curl wget tcpdump luci-app-wol 6in4 6to4 6rd usbutils usb-modeswitch kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-ether comgt-ncm kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan luci-proto-ncm luci-proto-3g avahi-dbus-daemon avahi-utils smcroute zerotier" EXTRA_IMAGE_NAME="apu2_2nic_byteandnibble" FILES=files/
