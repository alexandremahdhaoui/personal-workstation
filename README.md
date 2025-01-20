# personal-workstation

Please run the following script to bootstrap a Personal Workstation:

## Ubuntu

```shell
sudo apt-get install -y curl git
CLONE_DIR="${HOME}/go/src/github.com/alexandremahdhaoui"
mkdir -p "${CLONE_DIR}"
cd "${CLONE_DIR}"
git clone https://github.com/alexandremahdhaoui/personal-workstation.git
cd personal-workstation
./common/bootstrap.sh
```

## Arch

### Install Arch Linux

This script will install Arch Linux on your system. It will use standard partitioning to create a 1G EFI part, an 8GB
swap, and use the remaining space as your root directory. This root partition is fully encrypted using `dm-crypt` and
`luks`.

First, you'll need to flash the Arch Linux ISO on a USB key and boot it.
Then just run the following command:

```shell
curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/arch/install.sh | tee install.sh
chmod 755 install.sh
./install.sh
```

In case you need to configure wifi, you can run the following command:

```shell
iwctl device list

DEVICE="" # Set the device you want to connect to.
iwctl station "${DEVICE}" scan
iwctl station "${DEVICE}" get-networks

STATION="" # Set the station you want to connect to.
iwctl station "${DEVICE}" connect "${STATION}"
```

### Configure the system

The following script will install all the necessary packages and configure the system.

```shell
curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/arch/config.sh | tee config.sh
chmod 755 config.sh
./config.sh
```

### Bootstrap the system

The following script will generate ssh keys, install vib and clone your dataplane.

```shell
curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/arch/bootstrap.sh | tee bootstrap.sh
chmod 755 bootstrap.sh
./bootstrap.sh
```

## Fedora CoreOS

```shell
curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/fcos/bootstrap.sh | tee bootstrap.sh
chmod 755 bootstrap.sh
./bootstrap.sh
```
