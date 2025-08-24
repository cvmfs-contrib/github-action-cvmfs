#!/usr/bin/env bash
# macOS-specific CVMFS install logic
set -e

echo "warning: MacOS support is experimental."

brew tap macos-fuse-t/cask
brew tap cvmfs/homebrew-cvmfs
brew install cvmfs

# Create /cvmfs mountpoint using synthetic firmlink
sudo zsh -c 'echo -e "cvmfs\tUsers/Shared/cvmfs\n#comment\n" > /etc/synthetic.conf'
sudo chown root:wheel /etc/synthetic.conf
sudo chmod a+r /etc/synthetic.conf
sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t || true

# Mount repositories
for repo in $(echo ${CVMFS_REPOSITORIES} | sed "s/,/ /g")
do
  mkdir -p /Users/Shared/cvmfs/${repo}
  sudo mount -t cvmfs ${repo} /Users/Shared/cvmfs/${repo}
done
sleep 3
