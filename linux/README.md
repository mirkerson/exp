# Welcome to Mango Pi
# About
Mango Pi is a Open Source Board
    
# Features
```
CPU:    ALLWINNER V3S ARM Cortex-A7, max frequency 1.2G
DRR2:   integrated 512M DDR2 in SOC
ROM:    32MB SPI Nor Flash
LCD:    general 40P RGB LCD FPC socket
        
WIFI:   ESP8909 in Board
Interface:  
        SDIO
        SPI
        I2C
        UART
        100M Ethernet (contain EPHY)
        OTG USB
        MIPI CSI
        SPEAKER + MIC
        WIFI (esp8089)
        
```

### Build

```
cross_compiler:
 refer: https://github.com/mirkerson/tools
uboot:
 refer: https://github.com/mirkerson/u-boot

kernel:
 git clone https://github.com/mirkerson/linux.git

 make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mangopi_defconfig
 make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
 
 modules:
  esp8089 ./drivers/net/wireless/esp8089/esp8089.ko
  Do not forget to copy firmware/*.bin to /lib/firmware/ on the target system. 

 buildroot:
  refer: https://github.com/mirkerson/tools
```

### Flash
```
dd if=/dev/zero of=flashimg.bin bs=1M count=16;
dd if=u-boot/u-boot-sunxi-with-spl.bin of=flashimg.bin bs=1K conv=notrunc;
dd if=linux/arch/arm/boot/dts/sun8i-v3s-mangopi.dtb of=flashimg.bin bs=1K seek=1024 conv=notrunc;
dd if=linux/arch/arm/boot/zImage of=flashimg.bin bs=1K seek=1088 conv=notrunc;
dd if=tools/buildroot-2017.08/output/images/jffs2.img of=flashimg.bin bs=1K seek=5184 conv=notrunc;

press FLASH key, then plugin the usb cable.
sudo sunxi-fel -p spiflash-write 0 flashimg.bin

PS:
   sunxi-fel refer https://github.com/mirkerson/sunxi-tools
```

The Project use Large files, so You may install git lfs in https://git-lfs.github.com/

### Join the chat at QQ Group: 560888351 
