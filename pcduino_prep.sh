#!/bin/bash

. ${INCLUDE_DIR}/functions.sh

# Umount target if already mounted
umount ${TARGET_DEVICE}*
for swap_partition in $(swapon -s | grep ${TARGET_DEVICE} | cut -d ' ' -f1);
do
    swapoff ${swap_partition}
    check_result $?
done

# Erase partition table
dd if=/dev/zero of=${TARGET_DEVICE} bs=1024 count=1024

(echo "2048,131072,c,,
    ,,L,,
    ;
    ;" | sfdisk -fuS --in-order --no-reread ${TARGET_DEVICE})
check_result $?

partprobe ${TARGET_DEVICE}
check_result $?

# Format target
mkfs.vfat -n UBOOT $VFAT_DEVICE
check_result $?
mkfs.ext4 -L ${RANDOM} ${ROOTFS_DEVICE}
check_result $?
