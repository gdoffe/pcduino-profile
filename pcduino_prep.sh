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
    65,,L,*,
    ;
    ;" | sudo sfdisk -fuM --no-reread ${TARGET_DEVICE})
check_result $?

partprobe ${TARGET_DEVICE}
check_result $?

# Format target
mkfs.vfat $VFAT_DEVICE
check_result $?
mkfs.ext4 -F -L ${RANDOM} -m 0 ${ROOTFS_DEVICE}
check_result $?
