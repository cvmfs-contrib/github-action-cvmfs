#!/usr/bin/env bash

# Platform specific install
if [ "$(uname)" == "Linux" ]; then
  # download from cache
  if [ -n "${APT_CACHE}" ]; then
    echo "::group::Using cache"
    echo "Copying cache from ${APT_CACHE} to system locations..."
    mkdir -p ${APT_CACHE}/archives/
    sudo cp -r ${APT_CACHE}/archives /var/cache/apt
    if [ "${APT_CACHE_LISTS}" == "yes" ]; then
      mkdir -p ${APT_CACHE}/lists/
      sudo cp -r ${APT_CACHE}/lists /var/lib/apt
    fi
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
  sudo apt-get -q -y install cvmfs
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
    mkdir -p ${APT_CACHE}/archives/
    cp /var/cache/apt/archives/*.deb ${APT_CACHE}/archives/
    if [ "${APT_CACHE_LISTS}" == "yes" ]; then
      mkdir -p ${APT_CACHE}/lists/
      cp /var/lib/apt/lists/*_dists_* ${APT_CACHE}/lists/
    fi
    echo "::endgroup::"
  fi
  if [ -n "${CVMFS_CACHE_BASE}" ]; then
    echo "::group::Preparing cvmfs cache base"
    mkdir -p "${CVMFS_CACHE_BASE}"
    # Ensure the shared sub-directory exists so default ACLs are set on it too
    if [ "${CVMFS_SHARED_CACHE}" != "no" ]; then
      mkdir -p "${CVMFS_CACHE_BASE}/shared"
    fi
    sudo chown -R cvmfs:root "${CVMFS_CACHE_BASE}"
    sudo chmod -R a+rwX "${CVMFS_CACHE_BASE}"
    sudo find "${CVMFS_CACHE_BASE}" -type d -exec chmod a+rwx {} +
    # Set default POSIX ACLs so that files/directories created later by the
    # cvmfs user (during the job) are world-readable.  This is required for
    # the actions/cache post-job save step, which runs as the runner user.
    if command -v setfacl >/dev/null 2>&1; then
      sudo setfacl -R -d -m o::rwX "${CVMFS_CACHE_BASE}"
      sudo setfacl -R -m o::rwX "${CVMFS_CACHE_BASE}"
    fi
    id cvmfs
    sudo -u cvmfs id
    ls -ld "${CVMFS_CACHE_BASE}"
    sudo -u cvmfs test -w "${CVMFS_CACHE_BASE}"
    sudo -u cvmfs env CVMFS_CACHE_BASE="${CVMFS_CACHE_BASE}" bash <<'EOF'
set -euo pipefail
probe_file="${CVMFS_CACHE_BASE}/.cvmfs-write-probe"
printf 'probe\n' > "${probe_file}"
rm -f "${probe_file}"
EOF
    ls -ld "${CVMFS_CACHE_BASE}"
    sudo find "${CVMFS_CACHE_BASE}" -mindepth 1 -maxdepth 1 | sort || true
    test -r "${CVMFS_CACHE_BASE}"
    test -w "${CVMFS_CACHE_BASE}"
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
