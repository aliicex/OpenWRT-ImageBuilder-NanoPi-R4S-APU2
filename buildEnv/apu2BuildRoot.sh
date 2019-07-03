#!/bin/bash
#
# apu2BuildRoot.sh
#
# Creates the build environment required to re-build my image for APU2 boards with at least 2 NICs
#

### Prerequisites for buildroot
sudo apt-get update
sudo apt install build-essential git gitk libncurses5-dev gawk unzip wget curl ccache rsync zlib1g-dev


PS3='Please select your preferred OpenWRT release: '
options=("Snapshot" "18.06.4" "19.07" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Snapshot")
            echo "Using OpenWrt Snapshot"
            RELEASE='https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-imagebuilder-x86-64.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-x86-64.Linux-x86_64'
            break
            ;;
       "18.06.4")
            echo "Using OpenWrt 18.06.4"
            RELEASE='https://downloads.openwrt.org/releases/18.06.4/targets/x86/64/openwrt-imagebuilder-18.06.4-x86-64.Linux-x86_64.tar.xz'
            DIR='openwrt-imagebuilder-18.06.4-x86-64.Linux-x86_64'
            break
            ;;
        "19.07")
            echo "Using OpenWrt 19.07"
            RELEASE='https://downloads.openwrt.org/releases/19.07/targets/x86/64/openwrt-imagebuilder-19.07-x86-64.Linux-x86_64.tar.xz'
             DIR='openwrt-imagebuilder-19.07-x86-64.Linux-x86_64'
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
! grep -q 'stangri_repo' repositories.conf && sed -i '2 i\src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' repositories.conf

### make!
make clean
make image PACKAGES="luci -dnsmasq dnsmasq-full kmod-gpio-button-hotplug  kmod-crypto-hw-ccp kmod-leds-apu2 kmod-leds-gpio kmod-sp5100_tco kmod-usb-ohci kmod-usb2 kmod-usb3 kmod-gpio-nct5104d kmod-pcspkr kmod-usb-core kmod-sound-core libustream-mbedtls adblock luci-app-adblock luci-app-sqm luci-app-vpn-policy-routing luci-app-wireguard luci-proto-wireguard stubby unbound vpn-policy-routing luci-ssl curl wget luci-app-wol 6in4 6to4 6rd luci-theme-bootstrap luci-theme-material usbutils usb-modeswitch kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-ether comgt-ncm kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan luci-proto-ncm luci-proto-3g" EXTRA_IMAGE_NAME="apu2_2nic_geekinaboxx" FILES=files/