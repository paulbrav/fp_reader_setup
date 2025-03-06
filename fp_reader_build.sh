#!/bin/bash
set -ex

# =============================================================================
# Fingerprint Reader Setup Script for Pop!_OS on the Framework Laptop
# =============================================================================
# This script builds and installs the fingerprint reader packages from source
# rather than using pre-built packages. This approach follows the methodology
# described in Brett Kosinski's blog post:
# https://b-ark.ca/2021/09/06/debian-on-framework.html
#
# The script performs the following:
# 1. Installs necessary build dependencies
# 2. Builds libfprint from source
# 3. Builds fprintd from source
# 4. Installs the built packages
# 5. Configures the fingerprint authentication system
# =============================================================================

# Create a working directory
echo "Creating working directory..."
BUILD_DIR=$(mktemp -d -t fp-build-XXXXXXXXXX)
cd "$BUILD_DIR"

# =============================================================================
# Step 1: Install essential build dependencies
# =============================================================================
echo "Installing build dependencies..."
sudo apt update
sudo apt install -y build-essential devscripts debhelper git curl
sudo apt install -y libglib2.0-dev libgusb-dev libusb-1.0-0-dev libnss3-dev
sudo apt install -y libsystemd-dev libpolkit-gobject-1-dev libpam-dev
sudo apt install -y libelogind-dev libdbus-1-dev
sudo apt install -y meson ninja-build valac gtk-doc-tools

# =============================================================================
# Step 2: Build libfprint from source
# =============================================================================
echo "Building libfprint from source..."

# Download the Debian source package to get the packaging files
apt source --download-only libfprint-2-2
LIBFPRINT_DEB_SRC=$(ls libfprint-2*_*.debian.tar.xz | head -n 1)

# Clone the libfprint repository
git clone https://github.com/freedesktop/libfprint.git
cd libfprint

# Check out a compatible version (v1.94.3 for Framework support)
git checkout v1.94.3

# Extract the Debian packaging files
tar -xf ../"$LIBFPRINT_DEB_SRC" debian

# Create a new changelog entry for our version
cat > debian/changelog.new << EOF
libfprint-2-2 (2:1.94.3-1) unstable; urgency=medium

  * Custom build for Framework laptop fingerprint reader

 -- Framework User <user@pop-os>  $(date -R)

EOF
cat debian/changelog >> debian/changelog.new
mv debian/changelog.new debian/changelog

# Build the package
dpkg-buildpackage -b -uc -us

cd ..

# =============================================================================
# Step 3: Build fprintd from source
# =============================================================================
echo "Building fprintd from source..."

# Download the fprintd source package to get the packaging files
apt source --download-only fprintd
FPRINTD_DEB_SRC=$(ls fprintd*_*.debian.tar.xz | head -n 1)

# Clone the fprintd repository
git clone https://github.com/freedesktop/libfprint-fprintd.git fprintd
cd fprintd

# Check out a compatible version (v1.94.2 works well with libfprint 1.94.3)
git checkout v1.94.2

# Extract the Debian packaging files
tar -xf ../"$FPRINTD_DEB_SRC" debian

# Create a new changelog entry for our version
cat > debian/changelog.new << EOF
fprintd (1:1.94.2-1) unstable; urgency=medium

  * Custom build for Framework laptop fingerprint reader

 -- Framework User <user@pop-os>  $(date -R)

EOF
cat debian/changelog >> debian/changelog.new
mv debian/changelog.new debian/changelog

# Build the package
dpkg-buildpackage -b -uc -us

cd ..

# =============================================================================
# Step 4: Install the built packages
# =============================================================================
echo "Installing the built packages..."

# Install libfprint packages
sudo dpkg -i libfprint-2-2_*.deb libfprint-2-2-dev_*.deb libfprint-2-doc_*.deb gir1.2-fprint-2.0_*.deb

# Install fprintd packages (handle dependencies with apt)
sudo apt install -y -f
sudo dpkg -i fprintd_*.deb libpam-fprintd_*.deb python3-pyfprintd_*.deb
sudo apt install -y -f

# =============================================================================
# Step 5: Configure the fingerprint authentication system
# =============================================================================
echo "Configuring fingerprint authentication..."

# Enable and start the fprintd service
sudo systemctl enable fprintd.service
sudo systemctl start fprintd.service

# Enable fingerprint authentication for sudo
sudo pam-auth-update --enable fprintd

# =============================================================================
# Cleanup
# =============================================================================
echo "Cleaning up..."
cd
rm -rf "$BUILD_DIR"

echo "============================================================="
echo "Fingerprint reader installation complete!"
echo "To enroll fingerprints:"
echo "1. Open Settings"
echo "2. Go to 'Users'"
echo "3. Select 'Fingerprint Login'"
echo "4. Follow the enrollment process"
echo "=============================================================" 