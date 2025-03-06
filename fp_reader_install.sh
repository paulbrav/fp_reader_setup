#!/bin/bash
set -ex

# Fingerprint Reader Setup Script for Pop!_OS on the Framework Laptop
# Attribution:
#   Based on instructions from b-ark: https://b-ark.ca/2021/09/06/debian-on-framework.html
#   and resources from Elevated Systems (http://elevatedsystems.tech).

# Create temporary working directory
mkdir -p install_dir
cd install_dir

# Install dependency (Pop!_OS/Ubuntu)
sudo apt install -y curl

# Download custom debs
curl -O http://elevatedsystems.tech/media/scripts/libfprint_v1.94.1-2_debs.zip

# Unzip archive
unzip ./libfprint_v1.94.1-2_debs.zip

# Install dependency
sudo apt install -y gir1.2-gusb-1.0

# Install .deb files
cd fprintd
sudo dpkg -i ../*.deb
sudo dpkg -i ./*.deb

# Enable fingerprint service
sudo systemctl enable fprintd.service
sudo systemctl start fprintd.service

# Enable fingerprint PAM module for sudo functionality
sudo pam-auth-update --enable fprintd

# Clean up
cd ../..
sudo rm -rf install_dir 