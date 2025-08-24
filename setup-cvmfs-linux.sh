#!/usr/bin/env bash
# Linux-specific wrapper for CI/CD or local install
set -e

# Optional: handle APT cache for CI/CD
if [ -n "${APT_CACHE}" ]; then
  echo "Using cache from ${APT_CACHE}"
  mkdir -p ${APT_CACHE}/archives/ ${APT_CACHE}/lists/
  sudo cp -r ${APT_CACHE}/archives /var/cache/apt
  sudo cp -r ${APT_CACHE}/lists /var/lib/apt
fi

# Call shared install logic
sudo bash /workspaces/github-action-cvmfs/cvmfs-install-core.sh

# Optional: update cache after install
if [ -n "${APT_CACHE}" ]; then
  echo "Updating cache to ${APT_CACHE}"
  mkdir -p ${APT_CACHE}/archives/ ${APT_CACHE}/lists/
  cp /var/cache/apt/archives/*.deb ${APT_CACHE}/archives/
  cp /var/lib/apt/lists/*_dists_* ${APT_CACHE}/lists/
fi
