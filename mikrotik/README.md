# Installing OpenWRT on MikroTik RouterBOARD hAP ac<sup>2</sup> (RBD52G-5HacD2HnD-TC)

## Prerequisites

* Your router is running RouterOS v6. The bootloader from RouterOS v7 is not compatible with OpenWrt. If you need to, downgrade to RouterOS v6 using the ARM main package from https://mikrotik.com/download.
* An ethernet cable from your computer is plugged into port 2, 3, 4, or 5 on the router; it should be given an IP address from 192.168.88.1/24 from the DHCP pool.

1. 
    Save your RouterOS License .key file. This will allow you to use Mikrotik's NetInstall to [re-install RouterOS](https://wiki.mikrotik.com/wiki/Manual:Netinstall) later, if needed/desired.

    Log into the router's management interface (i.e. at http://192.168.88.1/). From a Terminal:

    ```
    /system license output
    ```

    Save the .key file from the file browser in the web interface and store it somewhere safe.

2. 
    Prepare:

    ```
    brew install dnsmasq
    mkdir ~/Desktop/openwrt-mikrotik
    ```

    Download the intramfs image (e.g. openwrt-22.03.0-ipq40xx-mikrotik-mikrotik_hap-ac2-initramfs-kernel.bin) from https://openwrt.org/toh/views/toh_fwdownload?dataflt%5BBrand*%7E%5D=mikrotik&datasrt=model&dataflt%5BModel*%7E%5D=RBD52G-5HacD2HnD-TC+ to `~/Desktop/openwrt-mikrotik`; e.g.:

    Save `loader.sh` to ~/Desktop/openwrt-mikrotik, then:

    ```
    chmod 755 loader.sh
    sudo ./loader.sh enX
    ```

    Replace `enX` with the interface identifier of your ethernet adapter (use `ifconfig` to find it out)

3. 
    FLASHING OPENWRT!

    Connect to mikrotik with winbox or by navigating to http://192.168.88.1

    System --> Routerboard --> Settings , "Boot Device" = "try-ethernet-once-then-nand" , "Boot Protocol" = "dhcp" , tick the "Force Backup Booter" checkbox , Click 'Apply and 'OK'

    Unplug the power from the router

    Connect the ethernet cable from the computer to port 1

    Power-up the router

    You'll see "vendor class: ARM__boot" and "bootfile name: openwrt-22.03.0-ipq40xx-mikrotik-mikrotik_hap-ac2-initramfs-kernel.bin" in the command line output from `loader.sh`

    Kill `loader.sh`

4.
    Verifying things...

    Connect the ethernet cable from the computer to port 2, 3, 4 or 5 on the router. You should receive an IP address from 192.168.1.1/24 and be able to ping 192.168.1.1 from your computer.

    Visit http://192.168.1.1 in a browser; the OpenWRT LuCI web interface should load.

    If it doesn't - don't panic! Since an initramfs image is just a temporary image (only loaded into RAM), when you power down your RouterBoard after loading an initramfs file, OpenWRT will simply vanish: a power down and reboot of the RouterBoard will revert to the prior version of firmware that is still in flash. 

    Once you are happy with the RAM-based operation of OpenWRT, you can write it permanently  into your RouterBoard:

    From the OpenWRT LuCI web interface:
    * Go to System→Backup/Flash Firmware
    * Click on 'Choose File' under 'Flash new firmware image'. Select your preferred sysupgrade .bin file (e.g. openwrt-22.03.0-ipq40xx-mikrotik-mikrotik_hap-ac2-squashfs-sysupgrade.bin from https://openwrt.org/toh/views/toh_fwdownload?dataflt%5BBrand*%7E%5D=mikrotik&datasrt=model&dataflt%5BModel*%7E%5D=RBD52G-5HacD2HnD-TC+)
    * Click on 'Flash image'. This will flash the sysupgrade .bin file into your RouterBoard and reboot it

    ## References
    https://github.com/ParsIOT/Openwrt_installation
    https://openwrt.org/toh/mikrotik/common