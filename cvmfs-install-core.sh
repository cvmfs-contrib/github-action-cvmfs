#!/usr/bin/env bash
# Shared CVMFS install and config logic for Linux
set -e

# Install CVMFS release package
CVMFS_UBUNTU_DEB_LOCATION=${CVMFS_UBUNTU_DEB_LOCATION:-https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb}
APT_ARCHIVES=/var/cache/apt/archives/
mkdir -p ${APT_ARCHIVES}
if [ ! -f ${APT_ARCHIVES}/cvmfs-release-latest_all.deb ] ; then
  curl -L -o ${APT_ARCHIVES}/cvmfs-release-latest_all.deb ${CVMFS_UBUNTU_DEB_LOCATION}
fi
dpkg -i ${APT_ARCHIVES}/cvmfs-release-latest_all.deb

# Install CVMFS and config package
apt-get -q update
apt-get -q -y install cvmfs ${CVMFS_CONFIG_PACKAGE:-cvmfs-config-default}

# Write config from environment variables
mkdir -p /etc/cvmfs

echo "# cvmfs default.local file installed by cvmfs-install-core.sh" > /etc/cvmfs/default.local
for var_name in $(compgen -A variable | grep ^CVMFS_)
do
  if [ -n "$(eval echo \$$var_name)" ]; then
    echo "$var_name='$(eval echo \$$var_name)'" >> /etc/cvmfs/default.local
  fi
done

cvmfs_config setup
