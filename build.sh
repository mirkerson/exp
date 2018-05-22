#/bin/sh 

TOP_DIR=`pwd`

UBOOT_DIR=$TOP_DIR/u-boot
KERNEL_DIR=$TOP_DIR/linux
SUNXI_TOOLS_DIR=$TOP_DIR/sunxi-tools
BUILDROOT_DIR=$TOP_DIR/buildroot-2017.08
TARGET_DIR=$TOP_DIR/target

QT_SRC_DIR=$TOP_DIR/qt-everywhere-opensource-src-4.8.6

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
	make O=out distclean
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
	make O=out distclean
}

function build_buildroot()
{
	echo "Build buildroot"

	cd $BUILDROOT_DIR
	
	make distclean

	cp configs/mangopi_buildroot_config .config

	make 
	
	if [ $? != "0" ] ; then
		echo "Build buildroot error!"
		exit
	fi
	
	rm -rf $TARGET_DIR

	mkdir -p $TARGET_DIR
	
	tar xvf $BUILDROOT_DIR/output/images/rootfs.tar -C $TARGET_DIR
	
}

function clean_buildroot()
{
	cd $BUILDROOT_DIR
	
	make clean
}

function build_qt()
{
	echo "==========Start Build QT=========="
	
	cd $QT_SRC_DIR

	rm -rf instal
	mkdir instal

	./configure \
	-prefix $QT_SRC_DIR/instal \
	-confirm-license \
	-embedded arm \
	-xplatform qws/arm-linux-gnueabihf-g++ \
	-release \
	-opensource  \
	-fast  \
	-no-accessibility  \
	-no-scripttools  \
	-no-mmx  \
	-no-multimedia  \
	-no-svg  \
	-no-3dnow  \
	-no-sse  \
	-no-sse2  \
	-no-libmng  \
	-no-libtiff  \
	-no-multimedia  \
	-silent  \
	-qt-libpng  \
	-qt-libjpeg  \
	-make libs  \
	-nomake translations \
	-no-nis \
	-no-cups \
	-no-iconv  \
	-no-dbus  \
	-no-openssl  \
	-little-endian \
	-qt-freetype  \
	-depths all \
	-qt-gfx-linuxfb  \
	-no-gfx-transformed  \
	-no-gfx-multiscreen  \
	-no-gfx-vnc  \
	-no-gfx-qvfb  \
	-qt-kbd-linuxinput  \
	-no-glib  \
	-qt-zlib \
	-no-phonon \
	-no-phonon-backend \
	-no-javascript-jit \
	-no-sql-db2  \
	-no-sql-ibase \
	-no-sql-oci \
	-no-sql-odbc \
	-no-sql-psql \
	-qt-sql-sqlite \
	-plugin-sql-sqlite \
	-no-sql-sqlite2 \
	-no-sql-mysql \
	-no-sql-tds \
	-no-qt3support \
	-qt-mouse-linuxinput \
	-no-mouse-linuxtp \
	-no-script \
	-no-largefile \
	-nomake docs  \
	-I$MINIGUI_INC_DIR \
	-L$MINIGUI_LIB_DIR \
	-D QT_QWS_CLIENTBLIT \
	-qt-mouse-linuxinput
	-no-mouse-linuxtp \
	-plugin-mouse-tslib \
	-nomake tools \
	-nomake docs  \
	-no-webkit \
	-stl \

#	-nomake demos \
#	-nomake examples \

	make clean
	make -j8
	make install
	
}

function clean_qt()
{
	cd $QT_DIR
	rm -rf instal
	make distclean
}

function build_qt_demos()
{
	echo "==========Start Build QT Demos=========="
	
	cd $QT_SRC_DIR/demos/embedded/styledemo
	export QTDIR=$QT_SRC_DIR
	export QTEDIR=$QTDIR
	export PATH=$QTDIR/bin:$PATH
	export LD_LIBRARY_PATH=$QTDIR/lib:$LD_LIBRARY_PATH 
	qmake -project
	qmake
	make
}

function pack()
{	
	# wifi 
	mkdir -p $TARGET_DIR/lib/modules
	mkdir -p $TARGET_DIR/lib/firmware
	cp $KERNEL_DIR/out/drivers/net/wireless/esp8089/esp8089.ko $TARGET_DIR/lib/modules/
	cp $KERNEL_DIR/drivers/net/wireless/esp8089/firmware/*.bin $TARGET_DIR/lib/firmware/

	#C++ lib
	cp $BUILDROOT_DIR/output/host/arm-buildroot-linux-gnueabihf/sysroot/lib/libstdc++.so.6 $TARGET_DIR/lib/ -af
	cp $BUILDROOT_DIR/output/host/arm-buildroot-linux-gnueabihf/sysroot/lib/libstdc++.so.6.0.22 $TARGET_DIR/lib/ -af

	#qt lib
	cp $QT_SRC_DIR/instal/lib/libQtGui.so.4 $TARGET_DIR/lib/ -af
	cp $QT_SRC_DIR/instal/lib/libQtGui.so.4.8.6 $TARGET_DIR/lib/ -af
	cp $QT_SRC_DIR/instal/lib/libQtNetwork.so.4 $TARGET_DIR/lib/ -af
	cp $QT_SRC_DIR/instal/lib/libQtNetwork.so.4.8.6 $TARGET_DIR/lib/ -af
	cp $QT_SRC_DIR/instal/lib/libQtCore.so.4 $TARGET_DIR/lib/ -af
	cp $QT_SRC_DIR/instal/lib/libQtCore.so.4.8.6 $TARGET_DIR/lib/ -af
	mkdir -p $TARGET_DIR/etc/fonts
	cp $QT_SRC_DIR/demos/embedded/styledemo/styledemo $TARGET_DIR/bin/

	arm-linux-gnueabihf-strip $TARGET_DIR/lib/*.so

	if [ `grep -c "QT_QWS_FONTDIR" $TARGET_DIR/etc/profile` -eq '0' ]; then
		echo "" >> $TARGET_DIR/etc/profile
		echo "export QT_QWS_FONTDIR=/lib/fonts" >> $TARGET_DIR/etc/profile
		echo "export QWS_MOUSE_PROTO=LinuxInput:/dev/input/event1" >> $TARGET_DIR/etc/profile

	fi
	
	#remove usr/lib
	rm -r $TARGET_DIR/usr
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
	build_sunxi_tools
	build_uboot
	build_kernel
	build_buildroot
	build_qt
	build_qt_demos
else
	case $1 in
	clean)
		clean_sunxi_tools
		clean_uboot
		clean_kernel
		clean_buildroot
		clean_qt
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
	build_qt)
		build_qt
		;;
	build_qt_demos)
		build_qt_demos
		;;
	pack)
		pack
		;;
	flash)
		flash
		;;
	esac
fi
