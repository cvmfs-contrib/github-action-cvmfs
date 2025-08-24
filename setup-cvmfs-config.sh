#!/usr/bin/env bash
# CVMFS configuration logic
set -e

echo "::group::Running cvmfs_config setup"
sudo cvmfs_config setup
retConfig=$?
if [ $retConfig -ne 0 ]; then
  echo "!!! github-action-cvmfs FAILED !!!"
  echo "cvmfs_config setup exited with ${retConfig}"
  exit $retConfig
fi
echo "::endgroup::"
