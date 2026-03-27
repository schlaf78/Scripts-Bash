#!/bin/bash

#Script allows to expand LVM partition on the fly without rebooting the server.  

#=== For SDC disck ONLY,  without extra disks in LVM !!! ===

echo "=== Step 1: Rescan disk ==="
echo 1 > /sys/class/block/sdc/device/rescan
[ $? -eq 0 ] && echo "[OK]" || { echo "[ERROR]"; exit 1; }

echo
echo "=== Step 2: Install growpart (if needed) ==="
yum install -y cloud-utils-growpart
[ $? -eq 0 ] && echo "[OK]" || { echo "[ERROR]"; exit 1; }

echo
echo "=== Step 3: Grow partition ==="
growpart /dev/sdc 1
[ $? -eq 0 ] && echo "[OK]" || { echo "[ERROR]"; exit 1; }

echo
echo "=== Step 4: Resize ext4 filesystem ==="
resize2fs /dev/sdc1
[ $? -eq 0 ] && echo "[OK]" || { echo "[ERROR]"; exit 1; }

echo
echo "=== Step 5: Check result ==="
df -h /var/spool/asterisk/monitor
[ $? -eq 0 ] && echo "[OK]" || { echo "[ERROR]"; exit 1; }

echo
echo "=== Done ==="