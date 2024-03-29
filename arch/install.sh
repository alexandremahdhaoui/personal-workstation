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

set_timezone() {
  timedatectl set-timezone Europe/Berlin
}

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
  pacstrap -K /mnt base linux linux-firmware base-devel man-db man-pages texinfo networkmanager iwd bash tmux vim intel-ucode git
  # removed lvm2
}

# setup_fstab
run_genfstab() {
  genfstab -U /mnt | tee -a /mnt/etc/fstab
}

setup_root() {
  echo "Please add [ 'systemd', 'keyboard', 'sd-vconsole', 'sd-encrypt' ] to /etc/mkinitcpio.conf"
  echo "Example: HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)"
  printf "Press ENTER wehn ready to edit the file..."
  read YOLO
  arch-chroot /mnt vim /etc/mkinitcpio.conf
  cat <<EOF | arch-chroot /mnt
echo "rd.luks.name=$(blkid | grep "${ROOTPART}" | sed 's/^.*UUID"//;s/".*//')" | tee /boot/loader/entries/arch.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
EOF

  echo "Please enter your hostname: "
  read NEW_HOSTNAME
  cat <<EOF | arch-chroot /mnt
echo "${NEW_HOSTNAME}" | tee /etc/hostname
echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" | tee /etc/locale.conf
EOF

  arch-chroot /mnt mkinitcpio -P
}

setup_user() {
  echo "Please enter name for your user:"
  read NEW_USER
  echo "Confirm username '${NEW_USER}' (y/n): "
  read CONFIRM
  if [[ "$CONFIRM" != "y" ]]; then setup_user; return;fi
  arch-chroot /mnt useradd -m -G wheel -s /usr/bin/bash "${NEW_USER}"
}

set_user_passwd() {
  echo "You will set the password for '${NEW_USER}'. Press ENTER when ready."
  read YOLO
  arch-chroot /mnt passwd ${NEW_USER}
  echo "Confirm new password (y/n): "
  read CONFIRM
  if [[ "$CONFIRM" != "y" ]]; then set_user_passwd; return;fi
}

setup_bootloader() {
  arch-chroot /mnt bootctl install
}

lets_reboot() {
  echo "Are you ready to reboot? (y/n) "
  read CONFIRM
  if [[ "$CONFIRM" != "y" ]]; then echo "Please run 'lets_reboot' when ready to umount and reboot your machine."; return;fi
 
  umount -R /mnt
  reboot
}

echo "TODO: remove wifi_setup from this file and add it to the README.md"
set_timezone
disk_select
disk_unsecure_erase
disk_partition
encrypt_root_part
setup_boot_part
setup_swap

echo "TODO: Update mirrorlist"
run_pacstrap
run_genfstab

setup_root
setup_user
set_user_passwd
setup_bootloader

lets_reboot
