# WIFI

# timedatectl Europe/Berlin

# PARTITION DISK
## Select DISK
IFS=\;
select DISK $(sudo fdisk -l | grep 'Disk /dev/' | sed -z 's/\n/;/g'); do
  echo $x
  break
done
IFS=" "

## Create /boot 1G
## Create /efi 1G
## Create root partition

