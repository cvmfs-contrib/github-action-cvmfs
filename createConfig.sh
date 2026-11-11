#!/usr/bin/env bash

declare -a vars=(CVMFS_ALIEN_CACHE
                 CVMFS_ALT_ROOT_PATH
                 CVMFS_AUTHZ_HELPER
                 CVMFS_AUTHZ_SEARCH_PATH
                 CVMFS_AUTO_UPDATE
                 CVMFS_BACKOFF_INIT
                 CVMFS_BACKOFF_MAX
                 CVMFS_CACHE_BASE
                 CVMFS_CATALOG_WATERMARK
                 CVMFS_CHECK_PERMISSIONS
                 CVMFS_CLAIM_OWNERSHIP
                 CVMFS_CLIENT_PROFILE
                 CVMFS_CONFIG_REPO_REQUIRED
                 CVMFS_DEBUGLOG
                 CVMFS_DEFAULT_DOMAIN
                 CVMFS_DNS_MAX_TTL
                 CVMFS_DNS_MIN_TTL
                 CVMFS_DNS_RETRIES
                 CVMFS_DNS_ROAMING
                 CVMFS_DNS_TIMEOUT
                 CVMFS_ENFORCE_ACLS
                 CVMFS_EXTERNAL_FALLBACK_PROXY
                 CVMFS_EXTERNAL_HTTP_PROXY
                 CVMFS_EXTERNAL_TIMEOUT
                 CVMFS_EXTERNAL_TIMEOUT_DIRECT
                 CVMFS_EXTERNAL_URL
                 CVMFS_FALLBACK_PROXY
                 CVMFS_FOLLOW_REDIRECTS
                 CVMFS_HIDE_MAGIC_XATTRS
                 CVMFS_HOST_RESET_AFTER
                 CVMFS_HTTP_PROXY
                 CVMFS_IGNORE_SIGNATURE
                 CVMFS_INITIAL_GENERATION
                 CVMFS_INSTRUMENT_FUSE
                 CVMFS_IPFAMILY_PREFER
                 CVMFS_KCACHE_TIMEOUT
                 CVMFS_KEYS_DIR
                 CVMFS_LOW_SPEED_LIMIT
                 CVMFS_MAX_EXTERNAL_SERVERS
                 CVMFS_MAX_IPADDR_PER_PROXY
                 CVMFS_MAX_RETRIES
                 CVMFS_MAX_SERVERS
                 CVMFS_MAX_TTL
                 CVMFS_MEMCACHE_SIZE
                 CVMFS_MOUNT_RW
                 CVMFS_NFILES
                 CVMFS_NFS_INTERLEAVED_INODES
                 CVMFS_NFS_SHARED
                 CVMFS_NFS_SOURCE
                 CVMFS_OOM_SCORE_ADJ
                 CVMFS_PAC_URLS
                 CVMFS_PROXY_RESET_AFTER
                 CVMFS_PROXY_TEMPLATE
                 CVMFS_PUBLIC_KEY
                 CVMFS_QUOTA_LIMIT
                 CVMFS_RELOAD_SOCKETS
                 CVMFS_REPOSITORIES
                 CVMFS_REPOSITORY_DATE
                 CVMFS_REPOSITORY_TAG
                 CVMFS_ROOT_HASH
                 CVMFS_SEND_INFO_HEADER
                 CVMFS_SERVER_CACHE_MODE
                 CVMFS_SERVER_URL
                 CVMFS_SHARED_CACHE
                 CVMFS_STRICT_MOUNT
                 CVMFS_SUID
                 CVMFS_SYSLOG_FACILITY
                 CVMFS_SYSLOG_LEVEL
                 CVMFS_SYSTEMD_NOKILL
                 CVMFS_TIMEOUT
                 CVMFS_TIMEOUT_DIRECT
                 CVMFS_TRACEFILE
                 CVMFS_USE_CDN
                 CVMFS_USE_GEOAPI
                 CVMFS_USER
                 CVMFS_USYSLOG
                 CVMFS_WORKSPACE
)

sudo mkdir -p /etc/cvmfs
echo "# cvmfs default.local file installed with cvmfs-contrib/github-action-cvmfs" | sudo tee /etc/cvmfs/default.local
for var_name in "${vars[@]}"
do
  if [ ! -z "$(eval "echo \$$var_name")" ]; then
    echo "$var_name='$(eval "echo \$$var_name")'" | sudo tee -a /etc/cvmfs/default.local
  fi
done
