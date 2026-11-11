#!/usr/bin/env bash

# Report a failed setup command and abort with its exit code
fail() {
  local ret=$1
  shift
  echo "::endgroup::"
  echo "::error::github-action-cvmfs: $* failed with exit code ${ret}"
  exit ${ret}
}

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
    sudo curl -L -o ${APT_ARCHIVES}/cvmfs-release-latest_all.deb ${CVMFS_UBUNTU_DEB_LOCATION} \
      || fail $? "downloading cvmfs-release"
  fi
  sudo dpkg -i ${APT_ARCHIVES}/cvmfs-release-latest_all.deb || fail $? "installing cvmfs-release"
  echo "::endgroup::"
  # install cvmfs package
  echo "::group::Installing cvmfs"
  sudo rm -f /var/lib/man-db/auto-update
  sudo apt-get -q update
  sudo apt-get -q -y install cvmfs || fail $? "apt-get install cvmfs"
  # install cvmfs config package
  if [ "${CVMFS_CONFIG_PACKAGE}" == "cvmfs-config-default" ]; then
    sudo apt-get -q -y install cvmfs-config-default || fail $? "apt-get install cvmfs-config-default"
  else
    sudo curl -L -o ${APT_ARCHIVES}/cvmfs-config.deb ${CVMFS_CONFIG_PACKAGE} \
      || fail $? "downloading ${CVMFS_CONFIG_PACKAGE}"
    sudo dpkg -i ${APT_ARCHIVES}/cvmfs-config.deb || fail $? "installing ${CVMFS_CONFIG_PACKAGE}"
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
elif [ "$(uname)" == "Darwin" ]; then
  echo "::warning::github-action-cvmfs: macOS support is experimental."

  # Install the CernVM-FS macOS package. Since 2.15 it provides an NFS backend
  # that relies only on the kernel NFS client and works on GitHub runners.
  # The package post-install runs 'cvmfs_config setup', which creates the
  # /cvmfs -> /Volumes/cvmfs firmlink and the /Users/Shared/cvmfs symlink.
  echo "::group::Installing cvmfs"
  PKG_CACHE=${APT_CACHE:-${RUNNER_TEMP:-/tmp}}/pkg
  PKG_FILE="${PKG_CACHE}/$(basename "${CVMFS_MACOS_PKG_LOCATION}")"
  mkdir -p "${PKG_CACHE}"
  if [ ! -f "${PKG_FILE}" ]; then
    curl -fL -o "${PKG_FILE}" "${CVMFS_MACOS_PKG_LOCATION}" \
      || { rm -f "${PKG_FILE}"; fail 1 "downloading ${CVMFS_MACOS_PKG_LOCATION}"; }
  fi
  sudo installer -pkg "${PKG_FILE}" -target / || fail $? "installing ${PKG_FILE}"
  # Workloads that open many files may need a higher limit
  sudo launchctl limit maxfiles 65536 65536 || true
  echo "::endgroup::"

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
  echo "::group::Mounting repositories"
  sudo cvmfs_config chksetup || echo "::warning::github-action-cvmfs: cvmfs_config chksetup reported problems"
  # There is no autofs on macOS: every repository is mounted explicitly,
  # starting with the config repository (if any).
  CONFIG_REPO=$(cat /etc/cvmfs/default.conf /etc/cvmfs/default.d/*.conf /etc/cvmfs/default.local 2>/dev/null \
    | sed -n "s/^[[:space:]]*CVMFS_CONFIG_REPOSITORY=[\"']*\([^\"']*\)[\"']*.*/\1/p" | tail -n 1)
  for repo in ${CONFIG_REPO} $(echo ${CVMFS_REPOSITORIES} | sed "s/,/ /g")
  do
    if mount | grep -q " on /Volumes/cvmfs/${repo} "; then
      continue
    fi
    mkdir -p /cvmfs/${repo} || fail $? "creating /cvmfs/${repo}"
    sudo mount -t cvmfs ${repo} /cvmfs/${repo} || fail $? "mounting ${repo}"
  done
  echo "::endgroup::"
fi
