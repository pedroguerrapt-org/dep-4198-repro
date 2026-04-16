# DEP-4198 repro

Reproduces the bug where job-level `if: startsWith(github.ref_name, 'release/')` is skipped on Depot CI.

## Steps

1. Push `main` — `deploy-production` should run (if: `github.ref_name == 'main'`), `deploy-staging` should be skipped.
2. Create and push a `release/test` branch — `deploy-staging` should run, `deploy-production` should be skipped.

**Before the fix**: both `deploy-staging` and `deploy-production` are always skipped because `github.ref_name` is missing from the orchestrator context.
