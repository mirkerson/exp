#/bin/sh 

TOP_DIR=`pwd`

UBOOT_DIR=$TOP_DIR/u-boot
KERNEL_DIR=$TOP_DIR/linux
SUNXI_TOOLS_DIR=$TOP_DIR/sunxi-tools
BUILDROOT_DIR=$TOP_DIR/buildroot-2017.08
MINIGUI_DIR=$TOP_DIR/minigui
ZLIB_DIR=$MINIGUI_DIR/zlib-1.2.11
LIBPNG_DIR=$MINIGUI_DIR/libpng-1.2.37
TSLIB_DIR=$MINIGUI_DIR/tslib-1.15
LIBMINIGUI_DIR=$MINIGUI_DIR/libminigui-3.0.12-linux
MGPLUS_DIR=$MINIGUI_DIR/libmgplus-1.2.4
MG_SAMPLES_DIR=$MINIGUI_DIR/mg-samples-3.0.12
MINIGUI_RES_DIR=$MINIGUI_DIR/minigui-res-be-3.0.12
TARGET_DIR=$TOP_DIR/target

MINIGUI_TARGET_DIR=$TOP_DIR/minigui/target
MINIGUI_LIB_DIR=$MINIGUI_TARGET_DIR/lib
MINIGUI_INC_DIR=$MINIGUI_TARGET_DIR/include

function build_sunxi_tools()
{
	cd $SUNXI_TOOLS_DIR
	make
	
	if [ $? != "0" ] ; then
		echo "Build sunxi-tools error!"
		exit
	fi

	sudo make install

	if [ $? != "0" ] ; then
		echo "Build sunxi-tools error!"
		exit
	fi

}

function clean_sunxi_tools()
{
	cd $SUNXI_TOOLS_DIR
	make clean
}

function build_uboot()
{
	cd $UBOOT_DIR
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O=out mangopi_defconfig
	
	if [ $? != "0" ] ; then
		echo "Build u-boot error!"
		exit
	fi

	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O=out

	if [ $? != "0" ] ; then
		echo "Build u-boot error!"
		exit
	fi

}

function clean_uboot()
{
	cd $UBOOT_DIR
	make distclean
}

function build_kernel()
{
	cd $KERNEL_DIR
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O=out mangopi_defconfig
	
	if [ $? != "0" ] ; then
		echo "Build kernel error!"
		exit
	fi

	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O=out -j8

	if [ $? != "0" ] ; then
		echo "Build kernel error!"
		exit
	fi
}

function clean_kernel()
{
	cd $KERNEL_DIR
	make distclean
}

function build_buildroot()
{
	cd $BUILDROOT_DIR
	
	cp configs/mangopi_buildroot_config .config

	make 
	
	if [ $? != "0" ] ; then
		echo "Build buildroot error!"
		exit
	fi
	
	rm -r $TARGET_DIR

	mkdir -p $TARGET_DIR
	
	tar xvf $BUILDROOT_DIR/output/images/rootfs.tar -C $TARGET_DIR
	
}

function clean_buildroot()
{
	cd $BUILDROOT_DIR
	
	make clean
}

function build_zlib()
{
	###build zlib
	cd $ZLIB_DIR
	export CC=arm-linux-gnueabihf-gcc
	
	./configure --shared --prefix=$MINIGUI_TARGET_DIR --libdir=$MINIGUI_LIB_DIR --includedir=$MINIGUI_INC_DIR
	
	if [ $? != "0" ] ; then
		echo "zlib configure error!"
		exit
	fi

	make 

	if [ $? != "0" ] ; then
		echo "build zlib error!"
		exit
	fi

	make install

}

function clean_zlib()
{
	cd $ZLIB_DIR
	make distclean
}

function build_libpng()
{
	###build libpng
	cd $LIBPNG_DIR
	./configure --prefix=$MINIGUI_TARGET_DIR \
		CC=arm-linux-gnueabihf-gcc \
		 --host=arm-linux --build=i386-linux --enable-shared\
		 LDFLAGS=-L$MINIGUI_LIB_DIR \
		 CFLAGS=-I$MINIGUI_INC_DIR \
		 LIBS=-lz

	if [ $? != "0" ] ; then
		echo "libpng configure error!"
		exit
	fi

	make 

	if [ $? != "0" ] ; then
		echo "build libpng error!"
		exit
	fi

	make install

}

function clean_libpng()
{
	cd $LIBPNG_DIR
	make distclean
}

function build_tslib()
{
	###build tslib
	cd $TSLIB_DIR
	./configure --host=arm-linux ac_cv_func_malloc_0_nonnull=yes \
		 --enable-linear=static --enable-input=static \
		 --enable-pthres=static --enable-variance=static --enable-dejitter=static \
		 -prefix=$MINIGUI_TARGET_DIR CC=arm-linux-gnueabihf-gcc 

	if [ $? != "0" ] ; then
		echo "tslib configure error!"
		exit
	fi

	make 

	if [ $? != "0" ] ; then
		echo "build tslib error!"
		exit
	fi

	make install

}

function clean_tslib()
{
	cd $TSLIB_DIR
	make distclean
}

function build_libminigui()
{
	###build libminigui
	cd $LIBMINIGUI_DIR
	./configure --prefix=$MINIGUI_TARGET_DIR \
		CC=arm-linux-gnueabihf-gcc \
		 --host=arm-linux --build=i386-linux --target=arm-linux --with-osname=linux \
                 --with-targetname=fbcon \
		 --enable-videofbcon \
		 --enable-autoial  \
		 --enable-tslibial  \
		 --disable-vbfsupport  \
		 --disable-screensaver \
		 --disable-pcxvfb \
	   	 --disable-dlcustomial \
		 --disable-cursor \
		 --enable-pngsupport \
		 CFLAGS=-I$MINIGUI_INC_DIR \
		 LDFLAGS=-L$MINIGUI_LIB_DIR 

	if [ $? != "0" ] ; then
		echo "libminigui configure error!"
		exit
	fi

	make 

	if [ $? != "0" ] ; then
		echo "build libminigui error!"
		exit
	fi

	make install

}

function clean_libminigui()
{
	cd $LIBMINIGUI_DIR
	make distclean
}

function build_mgplus()
{
	###build mgplus
	cd $MGPLUS_DIR
	./configure --prefix=$MINIGUI_TARGET_DIR \
		CC=arm-linux-gnueabihf-gcc \
		CXX=arm-linux-gnueabihf-g++ \
		 --host=arm-linux --build=i386-linux --target=arm-linux \
		 CFLAGS=-I$MINIGUI_INC_DIR \
		 CXXFLAGS=-I$MINIGUI_INC_DIR \
		 LDFLAGS=-L$MINIGUI_LIB_DIR \
		 MINIGUI_CFLAGS=-I$MINIGUI_INC_DIR \
		 MINIGUI_LIBS=-lminigui_ths \
		 PKG_CONFIG_PATH=$MINIGUI_LIB_DIR/pkgconfig \
		 LIBS="-lm -lz -lpng -lts"

	if [ $? != "0" ] ; then
		echo "mgplus configure error!"
		exit
	fi

	make 

	if [ $? != "0" ] ; then
		echo "build mgplus error!"
		exit
	fi

	make install

}

function clean_mgplus()
{
	cd $MGPLUS_DIR
	make distclean
}

function build_mg_samples()
{
	###build mg-samples
	cd $MG_SAMPLES_DIR
	./configure --prefix=$MINIGUI_TARGET_DIR \
		CC=arm-linux-gnueabihf-gcc \
		 --host=arm-linux --build=i386-linux --target=arm-linux \
		 --with-lang=zhcn \
		 CFLAGS=-I$MINIGUI_INC_DIR \
		 LDFLAGS=-L$MINIGUI_LIB_DIR \
		 MINIGUI_CFLAGS=-I$MINIGUI_INC_DIR \
		 MINIGUI_LIBS=-lminigui_ths \
		 PKG_CONFIG_PATH=$MINIGUI_LIB_DIR/pkgconfig \
		 LIBS="-lm -lz -lpng -lpthread -lts"

	if [ $? != "0" ] ; then
		echo "mg-samples configure error!"
		exit
	fi

	make 

	if [ $? != "0" ] ; then
		echo "build mg-samples error!"
		exit
	fi

	make install

}

function clean_mg_samples()
{
	cd $MG_SAMPLES_DIR
	make distclean
}

function build_minigui_res()
{
	###build minigui_res
	cd $MINIGUI_RES_DIR
	./configure --prefix=$MINIGUI_TARGET_DIR

	if [ $? != "0" ] ; then
		echo "minigui_ress configure error!"
		exit
	fi

	make 

	if [ $? != "0" ] ; then
		echo "build minigui_res error!"
		exit
	fi

	make install

}

function clean_minigui_res()
{
	cd $MINIGUI_RES_DIR
	make distclean
}

function build_minigui()
{
	build_zlib
	build_libpng
	build_tslib
	build_libminigui
	build_mgplus
	build_mg_samples
	build_minigui_res
}

function clean_minigui()
{
	clean_zlib
	clean_libpng
	clean_tslib
	clean_libminigui
	clean_mgplus
	clean_mg_samples
	clean_minigui_res
}

function pack()
{	
	# wifi 
	mkdir -p $TARGET_DIR/lib/modules
	mkdir -p $TARGET_DIR/lib/firmware
	cp $KERNEL_DIR/out/drivers/net/wireless/esp8089/esp8089.ko $TARGET_DIR/lib/modules/
	cp $KERNEL_DIR/drivers/net/wireless/esp8089/firmware/*.bin $TARGET_DIR/lib/firmware/
	
	# libz
	cp -d $MINIGUI_TARGET_DIR/lib/libz.so $TARGET_DIR/lib/
	cp -d $MINIGUI_TARGET_DIR/lib/libz.so.1 $TARGET_DIR/lib/
	cp -d $MINIGUI_TARGET_DIR/lib/libz.so.1.2.11 $TARGET_DIR/lib/

	# libpng12
	cp -d $MINIGUI_TARGET_DIR/lib/libpng12.so $TARGET_DIR/lib/ 
	cp -d $MINIGUI_TARGET_DIR/lib/libpng12.so.0 $TARGET_DIR/lib/ 
	cp -d $MINIGUI_TARGET_DIR/lib/libpng12.so.0.37.0 $TARGET_DIR/lib/ 

	# libts
	cp -d $MINIGUI_TARGET_DIR/lib/libts.so $TARGET_DIR/lib/ 
	cp -d $MINIGUI_TARGET_DIR/lib/libts.so.0 $TARGET_DIR/lib/ 
	cp -d $MINIGUI_TARGET_DIR/lib/libts.so.0.9.0 $TARGET_DIR/lib/ 

	#ts.conf
	cp $MINIGUI_TARGET_DIR/etc/ts.conf $TARGET_DIR/etc/
	if [ `grep -c "TSLIB_CONFFILE" $TARGET_DIR/etc/profile` -eq '0' ]; then
		echo "" >> $TARGET_DIR/etc/profile
		echo "export TSLIB_CONFFILE=/etc/ts.conf" >> $TARGET_DIR/etc/profile
	fi

	# libminigui
	cp -d $MINIGUI_TARGET_DIR/lib/libminigui_ths.so $TARGET_DIR/lib/
	cp -d $MINIGUI_TARGET_DIR/lib/libminigui_ths-3.0.so.12 $TARGET_DIR/lib/
	cp -d $MINIGUI_TARGET_DIR/lib/libminigui_ths-3.0.so.12.0.0 $TARGET_DIR/lib/

	# config
	cp $MINIGUI_TARGET_DIR/etc/MiniGUI.cfg $TARGET_DIR/etc/
	
	# res
	mkdir -p $TARGET_DIR/etc/res
	mkdir -p $TARGET_DIR/etc/res/font
	cp -r $MINIGUI_TARGET_DIR/share/minigui/res/bmp/ $TARGET_DIR/etc/res/
	cp -r $MINIGUI_TARGET_DIR/share/minigui/res/cursor/ $TARGET_DIR/etc/res/
	cp -r $MINIGUI_TARGET_DIR/share/minigui/res/icon/ $TARGET_DIR/etc/res/
	cp $MINIGUI_TARGET_DIR/share/minigui/res/font/song-12-gb2312.bin $TARGET_DIR/etc/res/font 
	cp $MINIGUI_TARGET_DIR/share/minigui/res/font/song-16-gb2312.bin $TARGET_DIR/etc/res/font
	
	#mg-samples
	cp $MG_SAMPLES_DIR/src/helloworld $TARGET_DIR/bin/
}

function clean_target()
{
	rm -r $TARGET_DIR
}


function flash()
{
	dd if=/dev/zero of=/tmp/flashimg.bin bs=1M count=16;
	dd if=$UBOOT_DIR/out/u-boot-sunxi-with-spl.bin of=/tmp/flashimg.bin bs=1K conv=notrunc;
	dd if=$KERNEL_DIR/out/arch/arm/boot/dts/sun8i-v3s-mangopi.dtb of=/tmp/flashimg.bin bs=1K seek=1024 conv=notrunc;
	dd if=$KERNEL_DIR/out/arch/arm/boot/zImage of=/tmp/flashimg.bin bs=1K seek=1088 conv=notrunc;

	sudo mkfs.jffs2 -s 0x100 -e 0x10000 -p 0x2f0000 -d $TARGET_DIR/ -o /tmp/jffs2.img
	dd if=/tmp/jffs2.img of=/tmp/flashimg.bin bs=1K seek=5184 conv=notrunc;

	FLASHIMG_SIZE=`ls -l /tmp/flashimg.bin | awk '{ print $5 }'`
	FLASHIMG_MAXSIZE=$((16*1024*1024))

	if [ $FLASHIMG_SIZE -gt $FLASHIMG_MAXSIZE ] ; then
		echo "Flash img too large"
	fi

	sudo sunxi-fel -p spiflash-write 0 /tmp/flashimg.bin
}


if [ $# -eq 0 ] ; then
	build_uboot
	build_kernel
	build_buildroot
	build_minigui
	pack
else
	case $1 in
	clean)
		clean_sunxi_tools
		clean_uboot
		clean_kernel
		clean_buildroot
		clean_minigui
		clean_target
		;;
	sunxi_tools)
		build_sunxi_tools
		;;
	uboot)
		build_uboot
		;;
	kernel)
		build_kernel
		;;
	buildroot)
		build_buildroot
		;;
	minigui)
		build_minigui
		;;
	pack)
		pack
		;;
	flash)
		flash
		;;
	esac
fi
