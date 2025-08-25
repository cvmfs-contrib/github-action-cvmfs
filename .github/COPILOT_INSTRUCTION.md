# GitHub Copilot Instruction

This repository is used globally by a large userbase and must support two major integration approaches:

1. **GitHub Actions (github-actions-cvmfs):**
   - The repository is included in CI/CD workflows by other projects using the composite GitHub Action defined in `action.yml`.
   - The action must work reliably on both Linux and macOS runners, using the modular scripts (`setup-cvmfs-linux.sh`, `setup-cvmfs-macos.sh`).
   - All configuration options and environment variables documented in `action.yml` must remain supported.

2. **Devcontainer Feature:**
   - The repository provides a devcontainer feature (`src/cvmfs`) for use in VS Code and other devcontainer environments.
   - The feature must install and configure CVMFS correctly in Ubuntu-based containers, using the modular setup.
   - The feature must remain compatible with the published OCI artifact and local development.

**Critical Guidance:**
- Any changes must preserve full functionality for both approaches.
- Avoid regressions: breaking either the GitHub Action or the devcontainer feature will impact many users and organizations worldwide.
- Test changes in both contexts before merging or releasing.
- Document any changes to configuration, environment variables, or usage in the README and relevant documentation files.

> **Copilot:** When assisting with this repository, always ensure that both the GitHub Action and devcontainer feature remain fully functional and compatible. Prioritize stability and backward compatibility for the global userbase.
