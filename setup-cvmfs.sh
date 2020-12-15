#!/bin/bash

# Install cvmfs
wget -q https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
sudo dpkg -i cvmfs-release-latest_all.deb
sudo apt-get -q update
sudo apt-get -q -y install cvmfs cvmfs-config-default
rm -f cvmfs-release-latest_all.deb

# Install custom config
if [ ! -z "${INPUT_CVMFS_CONFIG_PACKAGE}" ] ; then
  wget -O cvmfs-config.deb ${INPUT_CVMFS_CONFIG_PACKAGE}
  sudo dpkg -i cvmfs-config.deb
  rm -f cvmfs-config.deb
fi

# Setup default.local
sudo mkdir -p /etc/cvmfs
echo "CVMFS_REPOSITORIES=${INPUT_CVMFS_REPOSITORIES:-atlas.cern.ch,atlas-condb.cern.ch,grid.cern.ch}" | sudo tee /etc/cvmfs/default.local
echo "CVMFS_HTTP_PROXY=${INPUT_CVMFS_HTTP_PROXY:-DIRECT}" | sudo tee -a /etc/cvmfs/default.local
echo "CVMFS_USE_CDN=yes" | sudo tee -a /etc/cvmfs/default.local
sudo cvmfs_config setup

# Configure autofs
echo "+dir:/etc/auto.master.d" | sudo tee /etc/auto.master
sudo mkdir -p /etc/auto.master.d
echo "/cvmfs /etc/auto.cvmfs" | sudo tee /etc/auto.master.d/cvmfs.autofs
sudo service autofs start
