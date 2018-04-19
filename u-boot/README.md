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
 git clone https://github.com/mirkerson/u-boot.git

 make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mangopi_defconfig
 make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

```

### Flash
```
dd if=pi/u-boot/u-boot-sunxi-with-spl.bin of=flashimg.bin bs=1K conv=notrunc;

press FLASH key, then plugin the usb cable.
sudo ./sunxi-tools/sunxi-fel -p spiflash-write 0 /data/flashimg.bin

PS:
   sunxi-fel refer https://github.com/mirkerson/sunxi-tools
```

The Project use Large files, so You may install git lfs in https://git-lfs.github.com/

### Join the chat at QQ Group: 560888351 
