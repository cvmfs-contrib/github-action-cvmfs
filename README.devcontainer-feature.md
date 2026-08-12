# CVMFS Devcontainer Feature

This directory contains a devcontainer feature for installing and configuring the CVMFS client. The definition is located in the top-level directory to allow reuse of the GitHub Actions scripts.

## Publishing to GHCR

This feature is intended to be published to the GitHub Container Registry (GHCR) to be easily reusable by other projects.

### Manual Publishing

1.  **Install the Devcontainer CLI:**
    ```bash
    npm install -g @devcontainers/cli
    ```

2.  **Create a Personal Access Token (PAT):**
    *   Go to GitHub **Settings** > **Developer settings** > **Personal access tokens** > **Tokens (classic)**.
    *   Generate a new token with the `write:packages` scope.
    *   Export the token as an environment variable:
        ```bash
        export WRITE_PACKAGES_TOKEN=your-personal-access-token
        ```

3.  **Log in to GHCR:**
    ```bash
    echo $WRITE_PACKAGES_TOKEN | docker login ghcr.io -u your-github-username --password-stdin
    ```

4.  **Publish the Feature:**
    Run the following command from the root of this repository. The namespace should match the GitHub organization (`cvmfs-contrib`).
    ```bash
    devcontainer features publish --namespace cvmfs-contrib/github-action-cvmfs .
    ```

### Automated Publishing

This repository is configured with a GitHub Actions workflow to automate this process. When a new release is published on GitHub, the workflow will automatically build and publish the feature to GHCR.

For this to work, the `WRITE_PACKAGES_TOKEN` secret (a Personal Access Token with `write:packages` scope) must be configured in the repository's **Settings > Secrets and variables > Actions**.
