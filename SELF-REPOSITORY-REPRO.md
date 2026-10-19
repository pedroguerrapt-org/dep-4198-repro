# Depot GHA self-repository reference repro

This branch tests GitHub Actions `$/` self-repository references on Depot GitHub Actions runners.

The workflow tests Ubuntu 22.04 and 24.04 on x64 and ARM64, and a reusable workflow on Ubuntu 24.04 x64. It deliberately has no checkout step.

Each action verifies that:
- The workspace has no repository checkout.
- Its bundled marker exists.
- Its action download path contains the running commit SHA.
- Direct and nested action outputs report success.

The reusable workflow is itself called with `uses: $/.github/workflows/self-repo-reusable.yml` and runs the same direct and nested action checks.

Push to `repro/gha-self-repository-2026-10-19` to run. The prior Depot CI workflow is absent on this branch so only the GitHub Actions repro is triggered.
