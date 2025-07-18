#!/bin/bash

# Add packages
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic

# Update packages
rm -rf feeds/luci/applications/luci-app-passwall
cp -fr clone/amlogic/luci-app-amlogic feeds/luci/applications/

# Clean packages
rm -rf clone
