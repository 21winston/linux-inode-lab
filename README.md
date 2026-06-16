# Linux Filesystem Challenge: The Ghost-Full Filesystem

A hands-on Linux lab for simulating, diagnosing, and understanding inode exhaustion.

---

## Overview

One of the most confusing Linux storage problems occurs when a system reports:

```text
No space left on device
```

yet a storage check reveals plenty of free disk space.

This happens because Linux filesystems track two separate resources:

1. **Data Blocks** — store file contents.
2. **Inodes** — store file metadata.

A filesystem can run out of inodes long before it runs out of storage blocks. When that happens, new files cannot be created even though gigabytes of free space may remain available.

This lab recreates that scenario in a safe, disposable environment using a virtual disk image.

---

## Learning Objectives

After completing this lab, you should be able to:

* Explain the difference between blocks and inodes.
* Diagnose inode exhaustion using Linux tools.
* Interpret the outputs of `df -h` and `df -i`.
* Understand why free disk space does not always mean a filesystem can create new files.
* Work with loopback-mounted disk images.
* Safely mount, unmount, and clean up test filesystems.

---

## Filesystem Architecture

The lab creates a virtual disk image and mounts it as an EXT4 filesystem with an intentionally restricted inode count.

```text
┌──────────────────────┐
│      disk.img        │
│   Virtual Disk File  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│    Loop Device       │
│ (Mounted by Linux)   │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│    EXT4 Filesystem   │
├──────────────────────┤
│  Data Blocks         │
│  (File Contents)     │
├──────────────────────┤
│  Inodes              │
│  (File Metadata)     │
└──────────────────────┘
```

The script intentionally creates more files than the available inode count, causing inode exhaustion while leaving data blocks mostly unused.

---

## Repository Structure

```text
linux-inode-lab/
├── README.md
├── lab_manager.sh
├── disk.img          (generated)
└── lab_mount/        (generated)
```

---

## Prerequisites

* Linux (Ubuntu recommended)
* EXT4 filesystem tools
* sudo privileges
* Git

Verify required tools:

```bash
which mkfs.ext4
which mount
which umount
which df
```

---

## Installation

Clone the repository:

```bash
git clone <YOUR_REPOSITORY_URL>
cd linux-inode-lab
chmod +x lab_manager.sh
```

---

## Launch the Lab

Initialize the environment:

```bash
./lab_manager.sh --init
```

The script will:

1. Create a 20 MB virtual disk image.
2. Format it as EXT4 with only 128 inodes.
3. Mount it through a loop device.
4. Generate enough files to exhaust the inode supply.

Expected output:

```text
⚠️ LAB IS READY! ⚠️
Your virtual disk is mounted at: ./lab_mount
```

---

## Investigating the Problem

Move into the mounted filesystem:

```bash
cd lab_mount
```

Check available storage blocks:

```bash
df -h .
```

Example:

```text
Filesystem      Size  Used Avail Use%
/dev/loop0       17M  1.5M   15M   9%
```

The filesystem still has free space.

Now inspect inode usage:

```bash
df -i .
```

Example:

```text
Filesystem     Inodes IUsed IFree IUse%
/dev/loop0        128   128     0  100%
```

All inodes have been consumed.

Try creating another file:

```bash
touch test.txt
```

Result:

```text
touch: cannot touch 'test.txt':
No space left on device
```

The filesystem is not out of storage blocks.

It is out of inodes.

---

## Why This Happens

Each file requires:

* At least one inode
* Potentially many data blocks

Even an empty file consumes an inode.

When every inode is allocated:

* New files cannot be created.
* New directories cannot be created.
* Existing files can still be modified if space remains.

This is why inode exhaustion can be difficult to diagnose if you only check disk usage.

---

## Cleanup

Remove the lab safely:

```bash
cd ..
./lab_manager.sh --clean
```

The cleanup process:

* Unmounts the loop device
* Removes the mount directory
* Deletes the virtual disk image

Expected output:

```text
 CLEANUP COMPLETE 
```

---

## Real-World Relevance

Inode exhaustion commonly appears on:

* Web servers generating massive numbers of logs
* Email servers storing many small files
* Cache-heavy applications
* Containerized environments
* Backup systems

A system administrator who only checks:

```bash
df -h
```

may incorrectly conclude that storage is healthy.

Checking:

```bash
df -i
```

often reveals the real issue.

---

## Key Commands Learned

```bash
df -h
df -i
mkfs.ext4
mount
umount
touch
dd
```

---

## License

This project is provided for educational purposes and may be freely modified for learning and experimentation.
