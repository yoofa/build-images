#! /bin/sh
#
# install-depot_tools.sh
# Copyright (C) 2023 youfa <vsyfar@gmail.com>
#
# Distributed under terms of the GPLv2 license.
#

# install depot tols
# https://www.chromium.org/developers/how-tos/install-depot-tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /setup/depot_tools
#export PATH="/setup/depot_tools:$PATH"
echo "export PATH=\"/setup/depot_tools:$PATH\"" >>/home/builduser/.bashrc
