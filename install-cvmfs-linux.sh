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
if [ "${CVMFS_CONFIG_PACKAGE}" == "cvmfs-config-default" ]; then
  apt-get -q -y install cvmfs cvmfs-config-default
else
  curl -L -o ${APT_ARCHIVES}/cvmfs-config.deb ${CVMFS_CONFIG_PACKAGE}
  dpkg -i ${APT_ARCHIVES}/cvmfs-config.deb
fi

# Write config from environment variables
mkdir -p /etc/cvmfs

echo "# cvmfs default.local file installed by cvmfs-install-core.sh" > /etc/cvmfs/default.local
for var_name in $(compgen -A variable | grep ^CVMFS_)
do
  if [ -n "$(eval echo \$$var_name)" ]; then
    echo "$var_name='$(eval echo \$$var_name)'" >> /etc/cvmfs/default.local
  fi
done

# Configure CVMFS
bash create-config.sh
bash setup-cvmfs-config.sh

# Mount repositories
for repo in $(echo ${CVMFS_REPOSITORIES} | sed "s/,/ /g")
do
  sudo mount -t cvmfs ${repo} /cvmfs/${repo}
done
