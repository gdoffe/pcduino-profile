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
dd if=/dev/zero of=${TARGET_DEVICE} bs=1M count=1

(echo "1,64,0b,
    ,,L,*,
    ;
    ;" | sudo sfdisk -fuM --no-reread --in-order ${TARGET_DEVICE})
check_result $?

partprobe ${TARGET_DEVICE}
check_result $?

# Format target
mkfs.vfat -F 32 -n UBOOT $VFAT_DEVICE
check_result $?
mkfs.ext4 -L ${RANDOM} ${ROOTFS_DEVICE}
check_result $?
