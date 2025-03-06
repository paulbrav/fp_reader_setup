# Fingerprint Reader Setup for Pop!_OS on the Framework Laptop

This repository contains scripts to set up the fingerprint reader on Pop!_OS running on the Framework Laptop.

## Overview

This project provides two methods to set up your Framework laptop's fingerprint reader:

1. **Using pre-built packages** (`fp_reader_install.sh`): A quick and easy method using pre-built packages
2. **Building from source** (`fp_reader_build.sh`): A more customizable approach that builds packages from the official GitHub repositories

## Method 1: Using Pre-built Packages

The `fp_reader_install.sh` script performs the following tasks:

- Creates a temporary working directory
- Installs required dependencies
- Downloads and unpacks custom .deb packages for libfprint
- Installs the fingerprint reader packages
- Enables the fingerprint service and PAM module
- Cleans up temporary files

This method is faster but relies on pre-built packages hosted by Elevated Systems.

## Method 2: Building from Source

The `fp_reader_build.sh` script follows the approach detailed in Brett Kosinski's blog post. It:

- Installs all necessary build dependencies
- Downloads Debian packaging files
- Clones the libfprint and fprintd repositories from the official GitHub sources
- Checks out specific compatible versions known to work with the Framework laptop
- Builds the packages from source
- Installs the built packages
- Configures the fingerprint authentication system

This method takes longer but gives you more control and builds directly from the official sources.

## Usage

### Method 1: Pre-built Packages

```bash
chmod +x fp_reader_install.sh
./fp_reader_install.sh
```

### Method 2: Building from Source

```bash
chmod +x fp_reader_build.sh
./fp_reader_build.sh
```

The build-from-source method will take significantly longer (10-20 minutes depending on your system) as it compiles the packages from scratch.

## After Installation

After running either script, you can set up fingerprint login:

1. Open Settings
2. Go to "Users"
3. Select "Fingerprint Login"
4. Follow the enrollment process

You'll be able to use your fingerprint for login and sudo authentication.

## Troubleshooting

If you encounter issues:

- Make sure your Framework laptop's fingerprint reader is properly connected
- Check if the fprintd service is running: `systemctl status fprintd.service`
- For build errors, ensure you have a stable internet connection to download all dependencies

## Credits

- Based on instructions from [Brett Kosinski's blog](https://b-ark.ca/2021/09/06/debian-on-framework.html)
- Pre-built packages provided by Elevated Systems ([elevatedsystems.tech](http://elevatedsystems.tech))
- Official repositories by [freedesktop.org](https://github.com/freedesktop/)

## Disclaimer

Use these scripts at your own risk. They are intended for Pop!_OS on the Framework Laptop. 