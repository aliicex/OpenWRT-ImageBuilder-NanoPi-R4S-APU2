#!/bin/bash
#
# build.sh
#
# Creates the build environment required to re-build the images for my network devices: FriendlyARM NanoPi R4S, the PC Engines apu2 platform, and the Netgear WAC124 (as a dumb AP)
#

### Prerequisites for buildroot
sudo apt update
sudo apt install build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python

# https://openwrt.org/toh/pcengines/apu2
# https://teklager.se/en/knowledge-base/openwrt-installation-instructions/
#  for wle200nx, wle600vx or wle900vx WiFI adapters: 'hostapd-openssl kmod-ath9k ath9k-htc-firmware ath10k-firmware-qca988x kmod-ath10k'
PACKAGES_EXTRA='kmod-pcengines-apuv2 beep kmod-leds-gpio kmod-crypto-hw-ccp kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb3 kmod-sound-core kmod-pcspkr amd64-microcode flashrom irqbalance fstrim usbutils curl luci-app-advanced-reboot kmod-gpio-nct5104d kmod-gpio-button-hotplug kmod-sp5100-tco'

# https://openwrt.org/docs/guide-user/network/wan/smartphone.usb.tethering
PACKAGES_TETHERING='kmod-usb-net-rndis kmod-usb-net-cdc-ncm kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-eem kmod-usb-net-cdc-ether kmod-usb-net-cdc-subset kmod-nls-base kmod-usb-core kmod-usb-net kmod-usb2 kmod-usb-net-ipheth usbmuxd libimobiledevice usbutils'

PS3='Please select your preferred OpenWRT target: '
options=("r4s" "apu2" "wac124" "wax206" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "r4s")
            echo "Building image for NanoPi R4S"
            RELEASE='https://downloads.openwrt.org/releases/22.03.3/targets/rockchip/armv8/openwrt-imagebuilder-22.03.3-rockchip-armv8.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-22.03.3-rockchip-armv8.Linux-x86_64'
            PROFILE='friendlyarm_nanopi-r4s'
            unset PACKAGES_EXTRA
            break
            ;;
        "apu2")
            echo "Building image for PC Engines apu2 platform"
            RELEASE='https://downloads.openwrt.org/releases/22.03.3/targets/x86/64/openwrt-imagebuilder-22.03.3-x86-64.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-22.03.3-x86-64.Linux-x86_64'
            PROFILE='generic'
            break
          ;;
         "wac124")
            echo "Building image for Netgear WAC124"
            RELEASE='https://downloads.openwrt.org/releases/22.03.3/targets/ramips/mt7621/openwrt-imagebuilder-22.03.3-ramips-mt7621.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-22.03.3-ramips-mt7621.Linux-x86_64'
            PROFILE='netgear_wac124'
            break
          ;;
          "wac206")
            echo "Building image for Netgear WAX206"
            RELEASE='https://downloads.openwrt.org/snapshots/targets/mediatek/mt7622/openwrt-imagebuilder-mediatek-mt7622.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-mediatek-mt7622.Linux-x86_64'
            PROFILE='netgear_wax206'
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

DNSMASQFULL='-dnsmasq dnsmasq-full ipset libnettle8 libnetfilter-conntrack3'
# for Wireless APs install  wpad-mesh-openssl and remove wpad-mini 'wpad-mesh-openssl -wpad-mini'
BATMAN='kmod-batman-adv batctl'

# luci-proto-batman-adv banip luci-app-banip currently only available in SNAPSHOT
rm packages/*
cp ../packages/* packages/

# nftables-capable version of pbr.
# There's no nft sets support in OpenWrt's dnsmasq yet, you can't use dnsmasq set (dnsmasq.ipset) support
# https://forum.openwrt.org/t/vpn-policy-based-routing-web-ui-discussion/10389/1727
# https://docs.openwrt.melmac.net/pbr/
PBR='pbr luci-app-pbr resolveip ip-full'

### make!
make clean
if [ "$PROFILE" = 'netgear_wac124' ] || [ "$PROFILE" = 'netgear_wax206' ]; then
	make image PROFILE="$PROFILE" PACKAGES="-ppp -ppp-mod-pppoe -ip6tables -odhcp6c -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only luci nano luci-ssl auc luci-app-attendedsysupgrade $BATMAN" EXTRA_IMAGE_NAME="Llama-Alarm" DISABLED_SERVICES="dnsmasq firewall"
else
	make image PROFILE="$PROFILE" PACKAGES="luci luci-ssl nano $DNSMASQFULL kmod-ipt-nat6 luci-app-sqm sqm-scripts sqm-scripts-extra kmod-wireguard luci-app-wireguard luci-proto-wireguard wireguard-tools qrencode stubby unbound-daemon luci-app-unbound https-dns-proxy luci-app-https-dns-proxy watchcat luci-app-watchcat $PBR curl wget tcpdump etherwake luci-app-wol 6in4 6to4 6rd usb-modeswitch comgt-ncm kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan luci-proto-ncm luci-proto-3g avahi-dbus-daemon avahi-utils smcroute ntpclient auc luci-app-attendedsysupgrade $PACKAGES_EXTRA $PACKAGES_TETHERING $BATMAN" EXTRA_IMAGE_NAME="Llama-Alarm" DISABLED_SERVICES="stubby unbound pbr avahi-daemon etherwake https-dns-proxy"
fi