#!/usr/bin/env bash

set -e

# Use the shared core installer for Linux (relative path for feature packaging)
bash "$(dirname "$0")/../../cvmfs-install-core.sh"