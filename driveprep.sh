#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to install necessary libraries
install_libraries() {
    echo "Installing necessary libraries..."
    sudo apt update
    sudo apt install -y mdadm
    echo "Libraries installed successfully."
}

# Function to find drives of a specific size (5TB)
find_drives() {
    local SIZE="5000GB"
    echo "Finding drives of size $SIZE..."
    local DRIVES=($(lsblk -dno NAME,SIZE | awk -v size="$SIZE" '$2 == size {print "/dev/"$1}'))
    if [ ${#DRIVES[@]} -ne 2 ]; then
        echo "Error: Expected to find 2 drives of size $SIZE, but found ${#DRIVES[@]}"
        exit 1
    fi
    echo "Found drives: ${DRIVES[@]}"
    echo ${DRIVES[@]}
}

# Function to wipe, partition, and format a drive
prep_drive() {
    local DRIVE=$1
    echo "Preparing $DRIVE"

    # Wipe filesystem signatures
    echo "Wiping filesystem signatures on $DRIVE..."
    sudo wipefs --all $DRIVE

    # Create a new GPT partition table
    echo "Creating GPT partition table on $DRIVE..."
    sudo sgdisk --zap-all $DRIVE
    sudo sgdisk --new=1:0:0 --typecode=1:fd00 $DRIVE

    echo "$DRIVE preparation complete."
}

# Function to create RAID 1 array
create_raid() {
    local DRIVE1=$1
    local DRIVE2=$2
    echo "Creating RAID 1 array with $DRIVE1 and $DRIVE2..."

    # Create the RAID 1 array
    sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 ${DRIVE1}1 ${DRIVE2}1

    # Create filesystem on the RAID array
    sudo mkfs.ext4 /dev/md0

    # Mount the RAID array
    sudo mkdir -p /mnt/raid1
    sudo mount /dev/md0 /mnt/raid1

    # Save the RAID configuration
    sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
    sudo update-initramfs -u

    echo "RAID 1 array created and mounted at /mnt/raid1."
}

# Install necessary libraries
install_libraries

# Find 5TB drives
DRIVES=($(find_drives))

# Prepare each drive
for DRIVE in "${DRIVES[@]}"; do
    prep_drive $DRIVE
done

# Create RAID 1 array
create_raid ${DRIVES[0]} ${DRIVES[1]}

echo "RAID 1 setup complete. You can now proceed with the installation."
