#!/usr/bin/env bash

# WIFI
wifi_setup() {
  echo "Setting up wifi"
  iwctl station wlan0 scan
  iwctl station wlan0 get-networks
  echo "Please select a station: "
  read STATION
  iwctl station wlan0 connect "${STATION}" || wifi_setup
  echo "Successfully connected to wifi station ${STATION}"
}

# timedatectl Europe/Berlin

# PARTITION DISK
## Select DISK
disk_select() {
  sudo fdisk -l | grep 'Disk /dev/'
  echo "Please select a disk: "
  read DISK

  echo "Selected disk: '${DISK}'; CONFIRM (y/n): "
  read CONFIRM
  if [[ "$CONFIRM" != "y" ]]; then disk_select; return;fi
  printf "Successfully selected disk '${DISK}'"
}

## Unsecurely erase disk
disk_unsecure_erase() {
  dd if=/dev/zero of="${DISK}" bs=512 sectors=128
}

## Create /boot 1G & root partition
disk_partition() {
  cat <<EOF | tee /tmp/fdisk.conf
n
1

+1G
t
1
uefi
n
2

+8G
t
2
swap
n
3


p
q
EOF

  cat /tmp/fdisk.conf | fdisk "${DISK}"
  echo "Do you want to continue with default fdisk configuration? (y/n)"
  read CONFIRM
  if [[ "${CONFIRM}" != "y" ]]; then
    vim /tmp/fdisk.conf
  fi

  cat /tmp/fdisk.conf | sed 's/q/w/' | fdisk "${DISK}" 
}

# Encrypt root part
encrypt_root_part() {
  ROOTPART="${DISK}p3"
  cryptsetup -y -v luksFormat "${ROOTPART}"
  cryptsetup open ${ROOTPART} root
  mkfs.ext4 /dev/mapper/root
  mount /dev/mapper/root /mnt
}

# Boot partition
setup_boot_part() {
  BOOTPART="${DISK}p1"
  mkfs.fat -F 32 "${BOOTPART}"
  mount --mkdir "${BOOTPART}" /mnt/boot
}

# Swap
setup_swap() {
  SWAPPART="${DISK}p2"
  mkswap "${SWAPPART}"
  swapon "${SWAPPART}"
}

# run_pacstrap
run_pacstrap() {
  pacstrap -K /mnt base linux linux-firmware base-devel man-db man-pages texinfo networkmanager iwd bash vim
  # removed lvm2
}

# setup_fstab
run_genfstab() {
  genfstab -U /mnt | tee -a /mnt/etc/fstab
}

wifi_setup
disk_select
disk_unsecure_erase
disk_partition
encrypt_root_part
setup_boot_part
setup_swap

echo "TODO: Update mirrorlist"
run_pacstrap
run_genfstab

echo "Run 'arch-chroot /mnt' and continue the setup"

