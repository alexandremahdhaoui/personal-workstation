# personal-workstation

Please run the following script to bootstrap a Personal Workstation:

## Arch

### Install Arch Linux

This script will install Arch Linux on your system. You'll need to flash the Arch Linux ISO on a USB key and boot on it.
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
