# apu2_openwrt
This is my customised OpenWrt image for apu2 boards. It extends the generic x86_64 OpenWrt builds by:

* Kernel modules for specific APU2 features
* Additional APU2-specific packages: amd64-microcode, flashrom, irqbalance, fstrim
* Two ports are active by default: eth0 set to PPPoE WAN and using [CleanBrowsing's](https://cleanbrowsing.org) DNS resolvers; eth1 for LAN. 
* Adding LuCI with HTTPS SSL support; along with the LuCI Material theme in addition to the default bootstrap
* Replacing dnsmasq with dnsmasq-full
* IPv6: tunnel support for 6in4, 6to4, 6rd; NAT6 and IPv6 masquerading support (necessary evil for VPN providers which offer a single IPv6 address with a /128 prefix)
* SQM scripts
* Stubby, Unbound
* banIP
* vpn-policy-routing package
* Wireguard support
* USB v2 and v3.0 support
* wget, curl
* usbtools
* Limited support for 3G/4G USB modems via the ncm and 3g protocols (including the huawei_cdc_ncm driver)
* Wake-on-LAN LuCI module
* Avahi zero-configuration networking implementation

The images can be found in the bin/ directory of this repo. Note that _no warranty whatsoever is provided with these_.
 
# Recreating my build environment

I use the image builder rather than building from source. To create the builds, I use a Debian VM running in VirtualBox on MacOS. If you'd like to recreate my build environment, you can follow these instructions:

### Setting up a VM
1. Download & verify the [Debian netinst CD Image for amd64](https://www.debian.org/CD/netinst/). Later, this image can also be used to create a bootable USB which can be used to apply the OpenWrt image to the APU2's mSATA drive
2. Launch VirtualBox and create a new VM
3. Name the VM (e.g. Debian 10.4.0). Set the type as "Linux" and Version as "Debian (64-bit)"
4. Choose a memory size (RAM) for your VM. Note that the minimum memory requirement for Debian is 512MB
5. Choose ‘Create a virtual hard disk now’ option and click 'create'
6. Choose VDI, 'Dynamically allocated' options.
7. Provide a Hard Disk size (8GB fine for a minimal install: no graphical environment - just SSH server + base system, and the ImageBuilder deps)
8. Now click on ‘[Optical Drive] Empty’. Select ‘Choose disk image…’ and select the Debian netinst image that you downloaded
9. Start the VM and follow the installation instructions

During installation, you'll create a root user and non-root user. It's a good idea to grant sudo access to the non-root user:

```
su root
apt-get install sudo
adduser <username> sudo
exit
```

### Installing Guest Additions

This can be useful for sharing folders between the host and the VM. As root, do:

```
apt-get update
apt-get upgrade
apt-get install build-essential module-assistant
m-a prepare

```

Choose Devices > Insert Guest Additions from the VitualBox menu, and then:

```
mount /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run
```

Note that shared folders can be found in /media/*

### Building an customising an image

Clone this repo, and `cd` into `buildEnv`. Make `apu2BuildRoot.sh` executable by:

```
chmod 755 apu2BuildRoot.sh
```

modify the script if you wish: if you want wireless support, you'll need to install hostapd along with kmod-ath9k & ath9k-htc-firmware for the wle200nx; or ath10k-firmware-qca988x and kmod-ath10k for the wle600vx or wle900vx.

Now, go ahead and run it!

```
./apu2BuildRoot.sh
```

You'll be given the choice to build from Snapshot, 18.06.* or 19.07.*

### Testing the images
The built images will be located in the `bin` directory. These can be tested in VirtualBox:

1. Copy the image to the host machine and unzip it 
```
gzip -d openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img.gz
```
2. Run 
```
VBoxManage convertfromraw --format VDI openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.vdi
```

If you see an error like:

```
VBoxManage: error: VD: The given disk size 23499980 is not aligned on a sector boundary (512 bytes)
``` 

then run:

```
dd if=openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img of=openwrt.img bs=128000 conv=sync
```

followed by:

```
VBoxManage convertfromraw --format VDI openwrt.img openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.vdi
```

Finally, enlarge the image:

```
VBoxManage modifymedium openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.vdi --resize 128
```

3. Launch VirtualBox and create a new VM
4. Name the VM (e.g. OpenWRT). Set the type as "Linux" and Version as "Other Linux (64-bit)"
5. Accept the defaults, and then choose "Use an existing virtual hard disk file" selecting the VDI you created in the previous steps
6. Launch!

### Flash it (the easy way)!
1. Flash a copy of the PC Engines [TinyCore Linux distribution](https://pcengines.ch/howto.htm#TinyCoreLinux) to a USB drive using [balenaEtcher](https://www.balena.io/etcher/) or some other software.

2. Once written, the SYSLINUX partition on the USB Drive that you've just written should be mountable; put the Gzipped image (e.g. openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img.gz) onto it. Unmount the USB drive, disconnect it from your computer and connect it to the APU2.

3. Connect to the APU2 board using a serial to USB connector. On MacOS:

    * install the [CP210x USB to UART Bridge VCP Drivers](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)
    * Create a new Terminal profile (Terminal > Preferences). Configure the profile to run `screen /dev/cu.SLAB_USBtoUART 115200`on startup
    * Launch a new Terminal window with the profile you created

4. Boot the APU2 board. Press F10 to display a boot menu prompt, and select the USB drive; TinyCore will boot. TinyCore might try to mount some partition forever. Press Ctrl+C to cancel.

5. * Copy and unzip the image
    ```
    ~ # cp /media/SYSLINUX/openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img.gz .
    ~ # gunzip openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img.gz
    ```
    
    * Apply the image. Run `lsblk` to choose the correct device to which to write:
    ```
    ~ # dd if=openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img of=/dev/sda bs=4M; sync
    5+1 records in
    5+1 records out
    ```
   
6. All done! Remove the USB boot disk, cross your fingers, and `reboot`.

### Flash it (the longer way)!
1. Flash the Debian netinst amd64 iso to a USB drive using [balenaEtcher](https://www.balena.io/etcher/)

2. Connect to the APU2 board using a serial to USB connector. On MacOS:

    * install the [CP210x USB to UART Bridge VCP Drivers](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)
    * Create a new Terminal profile (Terminal > Preferences). Configure the profile to run `screen /dev/cu.SLAB_USBtoUART 115200`on startup
    * Launch a new Terminal window with the profile you created

3. Plug the USB drive into the APU, connect the serial cable, and a LAN cable in the port closest to the serial port.  Power up!  You should be greeted with the installer boot menu.  Select 'Help', then `F5` for "special boot parameters". At the boot prompt, enter `rescue console=ttyS0,115200n8`.  You will see a video mode error, press space to continue.

4. You are now in the rescue setup.  You should see `Rescue mode` at the time.  Choose your language, country, etc.  Skip loading any firmware, and choose `enp1s0` as your primary ethernet if prompted.  When it asks if you want to choose a root filesystem device, *scroll down* and choose "Do not use a root file system". Finally, you should be able to execute the rescue shell.

5. Once in the rescue shell:

    * Download and unzip the image
    ```
    ~ # wget https://raw.githubusercontent.com/NoMonkeyNoMission/apu2_openwrt/master/bin/19.07.6/openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img.gz
    ~ # gunzip openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img.gz
    ```
    
    * Apply the image. Run `lsblk` to choose the correct device to which to write:
    ```
    ~ # dd if=openwrt-19.07.6-apu2-2nic-nomonkeynomission-x86-64-combined-squashfs.img of=/dev/sda bs=4M; sync
    5+1 records in
    5+1 records out
    ```
    
    * Confirm the image application:
    ```
    ~ # parted /dev/sda print
    Number  Start   End     Size    Type     File system  Flags
     1      262kB   17.0MB  16.8MB  primary  ext2         boot
     2      17.3MB  286MB   268MB   primary
    ```

6. If you've used the ext4 image (rather than squashfs), you can (optionally) expand the partition to the rest of the disk size
    ```  
    ~ #  parted /dev/sda resizepart 2 16G
    Information: You may need to update /etc/fstab.
    
    ~# resize2fs /dev/sda2 
    ```
7. All done! Remove the USB boot disk, cross your fingers, and `reboot`.

## Useful stuff
1. To kill a screen session:

```
screen -X -S [session # you want to kill] quit
``` 

where session # is from:

```
screen -ls
```

### Firmware update for PC Engines APU2 systems

You'll need the following software:

* the latest [mainline firmware release](https://pcengines.github.io/) for your APU2 system 
* the PC Engines [TinyCore Linux distribution](https://pcengines.ch/howto.htm#TinyCoreLinux)
* [balenaEtcher](https://www.balena.io/etcher/) or some other software to flash the TinyCore image onto the USB drive

Use balenaEtcher to copy the TinyCore image onto the drive. Once written, the SYSLINUX partition on the USB Drive that you've just written should be mountable; put the .rom firmware file onto it. Unmount the USB drive, disconnect it from your computer and connect it to the apu2.

Connect to the APU2 using the Serial cable as described in the previous section. Press F10 to display a boot menu prompt, and select the USB drive; TinyCore will boot. TinyCore might try to mount some partition forever. Press Ctrl+C to cancel.

run:
```
flashrom -w /media/SYSLINUX/apuX_vX.X.X.X.rom -p internal
```

If you get a motherboard mismatch warning when trying to flash, run this command:
```
flashrom -w /media/SYSLINUX/apuX_vX.X.X.X.rom -p internal:boardmismatch=force
```

The firmware will be replaced. Shut down TinyCore with `reboot` and power cycle the APU2. The version number of your new firmware should be displayed during BIOS startup.
                               
If you brick it, you'll need a [flash recovery board](https://pcengines.ch/spi1a.htm)
