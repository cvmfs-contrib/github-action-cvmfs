# GitHub Action: cvmfs-contrib/github-action-cvmfs
[![ubuntu](https://github.com/cvmfs-contrib/github-action-cvmfs/workflows/ubuntu/badge.svg)](https://github.com/cvmfs-contrib/github-action-cvmfs/actions?query=workflow%3Aubuntu)

This GitHub Action sets up CernVM-FS for use in GitHub Workflows.

## Instructions
You can use this GitHub Action in a workflow in your own repository with `uses: cvmfs-contrib/github-action-cvmfs@v4`.

A minimal job example for GitHub-hosted runners of type `ubuntu-latest`:
```yaml
jobs:
  ubuntu-minimal:
    runs-on: ubuntu-latest
    steps:
    - uses: cvmfs-contrib/github-action-cvmfs@v4
    - name: Test CernVM-FS
      run: ls /cvmfs/sft.cern.ch/
```
By default 	`*.cern.ch, *.egi.eu, *.opensciencegrid.org *.hsf.org` repositories are available.

## Optional Parameters
The following parameters are supported:
- `cvmfs_alien_cache`: If set, use an alien cache at the given location.
- `cvmfs_alt_root_path`: If set to yes, use alternative root catalog path. Only required for fixed catalogs (tag / hash) under the alternative path.
- `cvmfs_authz_helper`: Full path to an authz helper, overwrites the helper hint in the catalog.
- `cvmfs_authz_search_path`: Full path to the directory that contains the authz helpers.
- `cvmfs_auto_update`: If set to no, disables the automatic update of file catalogs.
- `cvmfs_backoff_init`: Seconds for the maximum initial backoff when retrying to download data.
- `cvmfs_backoff_max`: Maximum backoff in seconds when retrying to download data.
- `cvmfs_cache_base`: Location (directory) of the CernVM-FS cache.
- `cvmfs_catalog_watermark`: Try to release pinned catalogs when their number surpasses the given watermark. Defaults to 1/4 CVMFS_NFILES; explicitly set by shrinkwrap.
- `cvmfs_check_permissions`: If set to no, disable checking of file ownership and permissions (open all files).
- `cvmfs_claim_ownership`: If set to yes, allows CernVM-FS to claim ownership of files and directories.
- `cvmfs_client_profile`: Chooses a suitable proxy automatically if set to `single`.
- `cvmfs_config_repo_required`: If set to yes, no repository can be mounted unless the config repository is available.
- `cvmfs_debuglog`: If set, run CernVM-FS in debug mode and write a verbose log the the specified file.
- `cvmfs_default_domain`: The default domain will be automatically appended to repository names when given without a domain.
- `cvmfs_dns_max_ttl`: Maximum effective TTL in seconds for DNS queries of proxy server names(not Stratum 1's). Defaults to 1 day.
- `cvmfs_dns_min_ttl`: Minimum effective TTL in seconds for DNS queries of proxy server names (not Stratum 1's). Defaults to 1 minute.
- `cvmfs_dns_retries`: Number of retries when resolving proxy names.
- `cvmfs_dns_roaming`: If true, watch /etc/resolv.conf for nameserver changes.
- `cvmfs_dns_timeout`: Timeout in seconds when resolving proxy names.
- `cvmfs_enforce_acls`: Enforce POSIX ACLs stored in the repository. Requires libfuse 3.
- `cvmfs_external_fallback_proxy`: List of HTTP proxies similar to CVMFS_EXTERNAL_HTTP_PROXY. The fallback proxies are added to the end of the normal proxies, and disable DIRECT connections.
- `cvmfs_external_http_proxy`: Chain of HTTP proxy groups to be used when CernVM-FS is accessing external data.
- `cvmfs_external_timeout`: Timeout in seconds for HTTP requests to an external-data server with a proxy server.
- `cvmfs_external_timeout_direct`: Timeout in seconds for HTTP requests to an external-data server without a proxy server.
- `cvmfs_external_url`: Semicolon-separated chain of webservers serving external data chunks.
- `cvmfs_fallback_proxy`: List of HTTP proxies similar to CVMFS_HTTP_PROXY. The fallback proxies are added to the end of the normal proxies, and disable DIRECT connections.
- `cvmfs_follow_redirects`: When set to yes, follow up to 4 HTTP redirects in requests.
- `cvmfs_hide_magic_xattrs`: If set to yes the client will not expose CernVM-FS specific extended attributes.
- `cvmfs_host_reset_after`: See CVMFS_PROXY_RESET_AFTER.
- `cvmfs_http_proxy`: Chain of HTTP proxy groups used by CernVM-FS. Set to DIRECT if you don’t use proxies.
- `cvmfs_ignore_signature`: When set to yes, don’t verify CernVM-FS file catalog signatures.
- `cvmfs_initial_generation`: Initial inode generation. Used for testing.
- `cvmfs_instrument_fuse`: When set to true gather performance statistics about the FUSE callbacks. The results are displayed with cvmfs_talk internal affairs.
- `cvmfs_ipfamily_prefer`: Which IP protocol to prefer when connecting to proxies. Can be either 4 or 6.
- `cvmfs_kcache_timeout`: Timeout for path names and file attributes in the kernel file system buffers.
- `cvmfs_keys_dir`: Directory containing `*.pub` files used as repository signing keys. If set, this parameter has precedence over CVMFS_PUBLIC_KEY.
- `cvmfs_low_speed_limit`: Minimum transfer rate a server or proxy must provide.
- `cvmfs_max_external_servers`: Limit the number of (geo sorted) stratum 1 servers for external data that are effectively used.
- `cvmfs_max_ipaddr_per_proxy`: Limit the number of IP addresses a proxy names resolves into. From all registered addresses, up to the limit are randomly selected.
- `cvmfs_max_retries`: Maximum number of retries for a given proxy/host combination.
- `cvmfs_max_servers`: Limit the number of (geo sorted) stratum 1 servers that are effectively used.
- `cvmfs_max_ttl`: Maximum file catalog TTL in minutes. Can overwrite the TTL stored in the catalog.
- `cvmfs_memcache_size`: Size of the CernVM-FS meta-data memory cache in Megabyte.
- `cvmfs_mount_rw`: Mount CernVM-FS as a read/write file system. Write operations will fail but this option can workaround faulty `open()` flags.
- `cvmfs_nfiles`: Maximum number of open file descriptors that can be used by the CernVM-FS process.
- `cvmfs_nfs_interleaved_inodes`: In NFS mode, use only inodes of the form an+b, specified as “b%a”.
- `cvmfs_nfs_shared`: If set, used to store the NFS maps in an SQlite database, instead of the usual LevelDB storage in the cache directory.
- `cvmfs_nfs_source`: If set to yes, act as a source for the NFS daemon (NFS export).
- `cvmfs_oom_score_adj`: Set the Linux kernel’s out-of-memory killer priority for the CernVM-FS client `[-1000 - 1000]`.
- `cvmfs_pac_urls`: Chain of URLs pointing to PAC files with HTTP proxy configuration information.
- `cvmfs_proxy_reset_after`: Delay in seconds after which CernVM-FS will retry the primary proxy group in case of a fail-over to another group.
- `cvmfs_proxy_template`: Overwrite the default proxy template in Geo-API calls. Only needed for debugging.
- `cvmfs_public_key`: Colon-separated list of repository signing keys.
- `cvmfs_quota_limit`: Soft-limit of the cache in Megabytes.
- `cvmfs_reload_sockets`: Directory of the sockets used by the CernVM-FS loader to trigger hotpatching/reloading.
- `cvmfs_repositories`: Comma-separated list of fully qualified repository names that shall be mountable under `/cvmfs`.
- `cvmfs_repository_date`: A timestamp in ISO format (e.g. `2007-03-01T13:00:00Z`). Selects the repository state as of the given date.
- `cvmfs_repository_tag`: Select a named repository snapshot that should be mounted instead of trunk.
- `cvmfs_root_hash`: Hash of the root file catalog, implies `CVMFS_AUTO_UPDATE=no`.
- `cvmfs_send_info_header`: If set to yes, include the cvmfs path of downloaded data in HTTP headers.
- `cvmfs_server_cache_mode`: Enable special cache semantics for a client used as a publisher’s repository base line.
- `cvmfs_server_url`: Semicolon-separated chain of Stratum 1 servers.
- `cvmfs_shared_cache`: If set to no, makes a repository use an exclusive cache.
- `cvmfs_strict_mount`: If set to yes, mount only repositories that are listed in `CVMFS_REPOSITORIES`.
- `cvmfs_suid`: If set to yes, enable suid magic on the mounted repository. Requires mounting as root.
- `cvmfs_syslog_facility`: If set to a number `n` between 0 and 7, uses the corresponding `LOCALn` facility for syslog messages.
- `cvmfs_syslog_level`: If set to 1 or 2, sets the syslog level for CernVM-FS messages to `LOG_DEBUG` or `LOG_INFO` respectively.
- `cvmfs_systemd_nokill`: If set to yes, modify the command line to `@vmfs2` ... in order to act as a systemd lowlevel storage manager.
- `cvmfs_timeout`: Timeout in seconds for HTTP requests with a proxy server.
- `cvmfs_timeout_direct`: Timeout in seconds for HTTP requests without a proxy server.
- `cvmfs_tracefile`: If set, enables the tracer and trace file system calls to the given file.
- `cvmfs_use_cdn`: Change the Stratum 1 endpoints to caching servers from Cloudflare.
- `cvmfs_use_geoapi`: Request order of Stratum 1 servers and fallback proxies via Geo-API.
- `cvmfs_user`: Sets the gid and uid mount options. Don’t touch or overwrite.
- `cvmfs_usyslog`: All messages that are normally logged to syslog are re-directed to the given file. This file can grow up to 500kB and there is one step of log rotation. Required for $mu$CernVM.
- `cvmfs_workspace`: Set the local directory for storing special files (defaults to the cache directory).
- `cvmfs_ubuntu_deb_location`: Location from where to download the Ubuntu deb package of CernVM-FS.
- `cvmfs_config_package`: URL to the cvmfs config package to install.
- `run_local_checkout`: Run the local checkout of the action and not the main repo code. Only used for testing and development of this action (needed in CI).

# Optional Parameters Defaults
All optional parameters are set by default to `''`(empty string). All variables that are set to this value are not propagated to `default.local`. The only exception to this are the following variables set to particular defaults:
 - `cvmfs_quota_limit`: `'15000'` (see [GitHub Runner Hardware](https://docs.github.com/en/free-pro-team@latest/actions/reference/specifications-for-github-hosted-runners#supported-runners-and-hardware-resources) before changing)
 - `cvmfs_client_profile`: `'single'`
 - `cvmfs_use_cdn`: `'yes'`
 - `cvmfs_ubuntu_deb_location`: `https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb`
 - `cvmfs_config_package`: `cvmfs-config-default`

## Minimal Example

The following minimal example, which is also a workflow in this repository at [.github/workflows/minimal-usage.yml](https://github.com/cvmfs-contrib/github-action-cvmfs/tree/main/.github/workflows/minimal-usage.yml), sets up CernVM-FS and lists the contents of the selected repositories from `*.cern.ch, *.egi.eu, *.opensciencegrid.org *.hsf.org`.
```yaml
name: Minimal usage
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: cvmfs-contrib/github-action-cvmfs@v4
    - name: Test CernVM-FS
      run: |
        ls /cvmfs/lhcb.cern.ch
        ls /cvmfs/auger.egi.eu
        ls /cvmfs/dune.opensciencegrid.org
        ls /cvmfs/sw.hsf.org
        ls /cvmfs/sft.cern.ch
```

## What Does This Action Do?

This GitHub Action installs the [CernVM-FS package](https://cernvm.cern.ch/fs/#download), and configures it with the  `CVMFS_CLIENT_PROFILE='single'` and `CVMFS_USE_CDN='yes'` to avoid any overhead on the CernVM-FS stratum 1 servers that you are accessing, this GitHub Action uses the [OpenHTC](https://openhtc.io) caching edge servers.

## Devcontainer Usage

This repository includes a pre-configured devcontainer for a consistent development environment. It uses the CVMFS devcontainer feature located in the `src/cvmfs` directory.

To use it, open this repository in a devcontainer-compatible editor like VS Code with the Dev Containers extension.

You can add other functionalities to your devcontainer by including more features. A comprehensive list of contributed features can be found in the [devcontainer feature index](https://github.com/devcontainers/devcontainers.github.io/blob/gh-pages/_data/collection-index.yml).

For example, you can add the following to your `devcontainer.json` to use this feature:
```json
{
    "name": "CVMFS Action Dev",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cvmfs-contrib/features/cvmfs:1": {
            "CVMFS_REPOSITORIES": "alice.cern.ch,atlas.cern.ch"
        }
    }
}
```

## Limitations

This GitHub Action is only expected to work in workflows that [run on](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#jobsjob_idruns-on) ubuntu. There is experimental support for `macOS` (11+).

 `windows` targets are not supported.

## Use With Docker

In case your workflow uses docker containers, the cvmfs directory can be mounted inside the container by using the flag `-v /cvmfs:/cvmfs:shared`.
