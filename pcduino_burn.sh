#!/bin/bash

. ${INCLUDE_DIR}/functions.sh

pwd=$PWD

build_path=$PROFILE_DIR
uboot_kernel_path=${build_path}/sunxi-bsp.git
boot_mount_point=/tmp/${RANDOM}

mkdir -p ${boot_mount_point}
check_result $?

cd $build_path
check_result $?

dd if=${uboot_kernel_path}/build/pcduino_hwpack/bootloader/sunxi-spl.bin of=${TARGET_DEVICE} bs=1024 seek=8
check_result $?

dd if=${uboot_kernel_path}/build/pcduino-u-boot/u-boot.img of=${TARGET_DEVICE} bs=1024 seek=40
check_result $?

sync
check_result $?

mount ${VFAT_DEVICE} ${boot_mount_point}
check_result $?

cp ${uboot_kernel_path}/build/pcduino_hwpack/kernel/* ${boot_mount_point} -f
check_result $?
sync
check_result $?

umount ${boot_mount_point}
check_result $?
rmdir ${boot_mount_point}
check_result $?

root_mount_point=/tmp/${RANDOM}

# Set partition label for kernel mount 
e2label ${ROOTFS_DEVICE} ${PARTITION_LABEL}
check_result $?

# Mount target 
mkdir -p ${root_mount_point}
check_result $?
mount ${ROOTFS_DEVICE}  ${root_mount_point}
check_result $?

# Copy rootfs to target 
cp -Rf --preserve=all ${TARGET_DIR}/* ${root_mount_point}/
check_result $?

# Umount and delete mountpoint 
umount ${root_mount_point}/
check_result $?
rmdir ${root_mount_point}/
check_result $?

cd $pwd
