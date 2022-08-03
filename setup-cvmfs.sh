#!/usr/bin/env bash

# Platform specific install
if [ "$(uname)" == "Linux" ]; then
  # install cvmfs release package
  APT_ARCHIVES=/var/cache/apt/archives/
  if [ ! -f ${APT_ARCHIVES}/cvmfs-release-latest_all.deb ] ; then
    sudo curl -L -o ${APT_ARCHIVES}/cvmfs-release-latest_all.deb ${CVMFS_UBUNTU_DEB_LOCATION}
  fi
  sudo dpkg -i ${APT_ARCHIVES}/cvmfs-release-latest_all.deb
  # install cvmfs package
  sudo apt-get -q update
  sudo apt-get -q -y install cvmfs
  # install cvmfs config package
  if [ "${CVMFS_CONFIG_PACKAGE}" == "cvmfs-config-default" ]; then
    sudo apt-get -q -y install cvmfs-config-default
  else
    sudo curl -L -o ${APT_ARCHIVES}/cvmfs-config.deb ${CVMFS_CONFIG_PACKAGE}
    sudo dpkg -i ${APT_ARCHIVES}/cvmfs-config.deb
  fi
elif [ "$(uname)" == "Darwin" ]; then
  # Warn about the phasing out of MacOS support for this action
  echo "::warning::The CernVM-FS GitHub Action's support for MacOS will be \
phased out with macos-10.15, which will be unsupported by GitHub by 8/30/22. \
See https://github.com/cvmfs-contrib/github-action-cvmfs/pull/17 for details."
  # Temporary fix for macOS until cvmfs 2.8 is released
  if [ -z "${CVMFS_HTTP_PROXY}" ]; then
    export CVMFS_HTTP_PROXY='DIRECT'
  fi
  brew install --cask macfuse
  curl -L -o cvmfs-latest.pkg ${CVMFS_MACOS_PKG_LOCATION}
  sudo installer -package cvmfs-latest.pkg -target /
else
  echo "Unsupported platform"
  exit 1
fi

${ACTION_PATH}/createConfig.sh

echo "Run cvmfs_config setup"
sudo cvmfs_config setup
retCongif=$?
if [ $retCongif -ne 0 ]; then
  echo "!!! github-action-cvmfs FAILED !!!"
  echo "cvmfs_config setup exited with ${retCongif}"
  exit $retCongif
fi


if [ "$(uname)" == "Darwin" ]; then
  for repo in $(echo ${CVMFS_REPOSITORIES} | sed "s/,/ /g")
  do
    mkdir -p /Users/Shared/cvmfs/${repo}
    sudo mount -t cvmfs ${repo} /Users/Shared/cvmfs/${repo}
  done
fi
