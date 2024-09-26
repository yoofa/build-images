#! /bin/sh
#
# install-deps.sh
# Copyright (C) 2023 youfa <vsyfar@gmail.com>
#
# Distributed under terms of the GPLv2 license.
#

set -e

apt-get update

package_list="
    curl \
    file \
    locales \
    lsb-release \
    python2 \
    python-dbus-dev \
    python-setuptools \
    python3-pip \
    sudo \
    wget \
    lsof \
    libfuse2 \
    software-properties-common \
    ninja-build"

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $package_list

update-alternatives --install /usr/bin/python python /usr/bin/python3 30

#add-apt-repository ppa:git-core/ppa -y && apt-get update

mkdir /setup
# Download deps installation files from Chromium
curl https://chromium.googlesource.com/chromium/src/+/HEAD/build/install-build-deps.sh\?format\=TEXT | base64 --decode | cat >/setup/install-build-deps.sh
curl https://chromium.googlesource.com/chromium/src/+/HEAD/build/install-build-deps.py\?format\=TEXT | base64 --decode | cat >/setup/install-build-deps.py

# Remove snapcraft to avoid issues on docker build
sed -i 's/packages.append("snapcraft")/print("skipping snapcraft")/g' /setup/install-build-deps.py

# Ensure installation files are executable
chmod +x /setup/install-build-deps.sh
chmod +x /setup/install-build-deps.py

DEBIAN_FRONTEND=noninteractive bash /setup/install-build-deps.sh --syms --no-prompt --no-chromeos-fonts --no-nacl

rm -rf /var/lib/apt/lists/*
