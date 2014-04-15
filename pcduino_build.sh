#!/bin/sh

. ${INCLUDE_DIR}/functions.sh

pwd=$PWD

build_path=$PROFILE_DIR
uboot_kernel_path=${build_path}/pcduino-uboot-kernel

mkdir -p $build_path

# Kernel
cd $build_path
if [ "$(git --git-dir ${uboot_kernel_path}/.git remote -v | tail -1 | grep '.*pcduino-uboot-kernel\.git.*')" = "" ]; then
    rm -Rf ${uboot_kernel_path}
    echo $build_path
    git clone https://github.com/geonobot/pcduino-uboot-kernel.git $uboot_kernel_path
    check_result $?
fi
cd ${uboot_kernel_path}
make clean
check_result $?
make update
check_result $?
x-terminal-emulator -e "make linux-config"
check_result $?
make 
check_result $?

if [ ${TARGET_DIR} != "" ]; then
	rm ${TARGET_DIR}/lib/modules/* -Rf
	mkdir -p ${TARGET_DIR}/lib/modules/
	check_result $?
	cp ${uboot_kernel_path}/build/pcduino_hwpack/rootfs/* ${TARGET_DIR}/ -ar
	check_result $?
	echo "# ttyS0 - getty
#
# This service maintains a getty on ttyS0 from the point the system is
# started until it is shut down again.

start on stopped rc or RUNLEVEL=[2345]
stop on runlevel [!2345]

respawn
exec /sbin/getty -L 115200 ttyS0 vt102" > ${TARGET_DIR}/etc/init/ttyS0.conf
	check_result $?
	sync
	check_result $?

	${CHROOT} userdel ubuntu
	${CHROOT} useradd -d /home/ubuntu -s /bin/bash -m -p `mkpasswd ubuntu` ubuntu
	check_result $?
	sed '/^ubuntu/d' ${TARGET_DIR}/etc/sudoers > ${TARGET_DIR}/etc/sudoers
	check_result $?
	echo "ubuntu ALL=(ALL) ALL" >> ${TARGET_DIR}/etc/sudoers
	check_result $?
else
	echo "Error : $TARGET_DIR is empty !" > /dev/stderr
	exit 1
fi

cd $pwd
