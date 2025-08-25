#!/usr/bin/env bash

# Fail on errors
set -e

# Platform specific install
if [ "$(uname)" == "Linux" ]; then
  # download from cache
  if [ -n "${APT_CACHE}" ]; then
    echo "::group::Using cache"
    echo "Copying cache from ${APT_CACHE} to system locations..."
    mkdir -p ${APT_CACHE}/archives/ ${APT_CACHE}/lists/
    sudo cp -r ${APT_CACHE}/archives /var/cache/apt
    sudo cp -r ${APT_CACHE}/lists /var/lib/apt
    echo "::endgroup::"
  fi
  # install cvmfs release package
  echo "::group::Installing cvmfs-release"
  APT_ARCHIVES=/var/cache/apt/archives/
  if [ ! -f ${APT_ARCHIVES}/cvmfs-release-latest_all.deb ] ; then
    sudo curl -L -o ${APT_ARCHIVES}/cvmfs-release-latest_all.deb ${CVMFS_UBUNTU_DEB_LOCATION}
  fi
  sudo dpkg -i ${APT_ARCHIVES}/cvmfs-release-latest_all.deb
  echo "::endgroup::"
  # install cvmfs package
  echo "::group::Installing cvmfs"
  sudo rm -f /var/lib/man-db/auto-update
  sudo apt-get -q update
  # Attempt install
  sudo apt-get -q -y install cvmfs
  if [ $? -ne 0 ]; then
    # If it fails, try to clear cache and try again
    echo "First attempt to install cvmfs failed, trying to clear cache and retrying"
    sudo rm -rf /var/cache/apt/archives
    sudo rm -rf /var/cache/apt/lists
    sudo apt-get -q update
    sudo apt-get -q -y install cvmfs
  fi
  # install cvmfs config package
  if [ "${CVMFS_CONFIG_PACKAGE}" == "cvmfs-config-default" ]; then
    sudo apt-get -q -y install cvmfs-config-default
  else
    sudo curl -L -o ${APT_ARCHIVES}/cvmfs-config.deb ${CVMFS_CONFIG_PACKAGE}
    sudo dpkg -i ${APT_ARCHIVES}/cvmfs-config.deb
  fi
  sudo touch /var/lib/man-db/auto-update
  echo "::endgroup::"
  # update cache (avoid restricted partial directories)
  if [ -n "${APT_CACHE}" ]; then
    echo "::group::Updating cache"
    echo "Copying cache from system locations to ${APT_CACHE}..."
    mkdir -p ${APT_CACHE}/archives/ ${APT_CACHE}/lists/
    cp /var/cache/apt/archives/*.deb ${APT_CACHE}/archives/
    cp /var/lib/apt/lists/*_dists_* ${APT_CACHE}/lists/
    echo "::endgroup::"
  fi
elif [ "$(uname)" == "Darwin" ]; then
  # Warn about the phasing out of MacOS support for this action
  echo "warning The CernVM-FS GitHub Action's support for MacOS  \
        is still experimental."

  brew tap macos-fuse-t/cask
  brew tap cvmfs/homebrew-cvmfs
  brew install cvmfs


  # / is readonly on macos 11+ - do 'synthetic firmlink' to create /cvmfs
  sudo zsh -c 'echo -e "cvmfs\tUsers/Shared/cvmfs\n#comment\n" > /etc/synthetic.conf'
  sudo chown root:wheel /etc/synthetic.conf
  sudo chmod a+r /etc/synthetic.conf
  # apfs.util seems to return non-zero error codes also on success
  sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t || true

else
  echo "Unsupported platform"
  exit 1
fi

${ACTION_PATH}/createConfig.sh

echo "::group::Running cvmfs_config setup"
sudo cvmfs_config setup
retCongif=$?
if [ $retCongif -ne 0 ]; then
  echo "!!! github-action-cvmfs FAILED !!!"
  echo "cvmfs_config setup exited with ${retCongif}"
  exit $retCongif
fi
echo "::endgroup::"


if [ "$(uname)" == "Darwin" ]; then
  for repo in $(echo ${CVMFS_REPOSITORIES} | sed "s/,/ /g")
  do
    mkdir -p /Users/Shared/cvmfs/${repo}
    sudo mount -t cvmfs ${repo} /Users/Shared/cvmfs/${repo}
  done
  # Fuse-t can have a brief lag after mounting  before the mountpoint responds 
  sleep 3
fi
