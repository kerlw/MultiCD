#!/bin/sh
set -e
. ./functions.sh
#Debian install CD/DVD plugin for multicd.sh
#version 6.6
#Copyright (c) 2011 libertyernie
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
if [ $1 = links ];then
	#Note the 6 - only Squeeze picked up
	echo "debian-6*.iso debian-install.iso none"
elif [ $1 = scan ];then
	if [ -f debian-install.iso ];then
		echo "Debian installer"
	fi
elif [ $1 = copy ];then
	if [ -f debian-install.iso ];then
		echo "Copying Debian installer..."
		mcdmount debian-install
		cp -r $MNT/debian-install/.disk $WORK
		cp -r $MNT/debian-install/dists $WORK
		cp -r $MNT/debian-install/install.* $WORK
		cp -r $MNT/debian-install/pool $WORK
		cp $MNT/debian-install/dedication.txt $WORK || true
		umcdmount debian-install
	fi
elif [ $1 = writecfg ];then
if [ -f debian-install.iso ];then
if [ -f $WORK/.disk/info ];then
	DEBNAME="$(cat $WORK/.disk/info)"
else
	DEBNAME="Debian GNU/Linux installer"
fi

DIR=debnotfounderror
for i in $(echo $WORK/install.*);do
	if [ -f $i/vmlinuz ];then
		DIR=$(basename $i)
	fi
done
if [ $DIR = "debnotfounderror" ];then
	echo "Error: install.* directory not found for Debian installer."
	echo "Debian installer will not work on this CD."
fi

echo "menu begin --> ^$DEBNAME

label install
	menu label ^Install
	menu default
	kernel /$DIR/vmlinuz
	append vga=normal initrd=/$DIR/initrd.gz -- quiet 
label expert
	menu label ^Expert install
	kernel /$DIR/vmlinuz
	append priority=low vga=normal initrd=/$DIR/initrd.gz -- 
label rescue
	menu label ^Rescue mode
	kernel /$DIR/vmlinuz
	append vga=normal initrd=/$DIR/initrd.gz rescue/enable=true -- quiet 
label auto
	menu label ^Automated install
	kernel /$DIR/vmlinuz
	append auto=true priority=critical vga=normal initrd=/$DIR/initrd.gz -- quiet 
label installgui
	menu label ^Graphical install
	kernel /$DIR/vmlinuz
	append video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz -- quiet 
label expertgui
	menu label Graphical expert install
	kernel /$DIR/vmlinuz
	append priority=low video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz -- 
label rescuegui
	menu label Graphical rescue mode
	kernel /$DIR/vmlinuz
	append video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz rescue/enable=true -- quiet  
label autogui
	menu label Graphical automated install
	kernel /$DIR/vmlinuz
	append auto=true priority=critical video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz -- quiet 
label Back to main menu
	com32 menu.c32
	append isolinux.cfg

menu end" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
