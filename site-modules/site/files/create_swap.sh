#!/bin/sh

/bin/dd if=/dev/zero of=/swapfile bs=1M count=1024
/sbin/mkswap /swapfile
/sbin/swapon /swapfile

# Add to /etc/fstab
cat >> /etc/fstab <<SWAP
    /swapfile       none            swap    sw              0       0
SWAP
