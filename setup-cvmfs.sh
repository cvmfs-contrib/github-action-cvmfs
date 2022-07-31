#!/usr/bin/env bash

#Platform specific install
if [ "$(uname)" == "Linux" ]; then
  echo "::group::curl and dpkg latest cvmfs release"
  curl -L -o cvmfs-release-latest_all.deb ${CVMFS_UBUNTU_DEB_LOCATION}
  sudo dpkg -i cvmfs-release-latest_all.deb
  echo "::endgroup::"
  echo "::group::apt-get update"
  sudo apt-get -q update
  echo "::endgroup::"
  echo "::group::apt-get install"
  sudo apt-get -q -y install cvmfs
  echo "::endgroup::"
  rm -f cvmfs-release-latest_all.deb
  if [ "${CVMFS_CONFIG_PACKAGE}" == "cvmfs-config-default" ]; then
    sudo apt-get -q -y install cvmfs-config-default
  else
    curl -L -o cvmfs-config.deb ${CVMFS_CONFIG_PACKAGE}
    sudo dpkg -i cvmfs-config.deb
    rm -f cvmfs-config.deb
  fi
elif [ "$(uname)" == "Darwin" ]; then
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

if [ "$1" == "local" ]; then
  . createConfig.sh
else
  $THIS/createConfig.sh
fi

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
