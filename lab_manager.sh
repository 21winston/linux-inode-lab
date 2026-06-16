#!/bin/bash

set -e

IMAGE_NAME="disk.img"
MOUNT_DIR="./lab_mount"

init_lab() {
echo "[+] Creating 20MB virtual disk image..."
dd if=/dev/zero of="$IMAGE_NAME" bs=1M count=20 status=none

```
echo "[+] Formatting EXT4 filesystem with 128 inodes..."
mkfs.ext4 -N 128 "$IMAGE_NAME" > /dev/null 2>&1

echo "[+] Creating mount point..."
mkdir -p "$MOUNT_DIR"

echo "[+] Mounting loopback filesystem (sudo required)..."
sudo mount -o loop "$IMAGE_NAME" "$MOUNT_DIR"

echo "[+] Giving ownership to current user..."
sudo chown "$USER:$USER" "$MOUNT_DIR"

echo "[+] Creating files until inode exhaustion occurs..."

cd "$MOUNT_DIR"

for i in $(seq 1 130); do
    touch "spam_file_$i.txt" 2>/dev/null || true
done

echo
echo "=================================================="
echo "LAB READY"
echo "=================================================="
echo
echo "Run:"
echo "  cd lab_mount"
echo "  df -h ."
echo "  df -i ."
echo "  touch test.txt"
echo
echo "Observe that storage space remains,"
echo "but no free inodes are available."
```

}

clean_lab() {
echo "[+] Cleaning up..."

```
if mountpoint -q "$MOUNT_DIR"; then
    sudo umount "$MOUNT_DIR"
fi

rm -rf "$MOUNT_DIR"
rm -f "$IMAGE_NAME"

echo
echo "Cleanup complete."
```

}

case "$1" in
--init)
init_lab
;;
--clean)
clean_lab
;;
*)
echo "Usage:"
echo "  $0 --init"
echo "  $0 --clean"
exit 1
;;
esac
