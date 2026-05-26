# Changelog

## [1.0.3] - 2026-05-26

### Added
- Multi-template support: auto-discovers and processes all OpenShift templates in a repository
- `Validate=false` sync-options annotation injected on all processed resources for OpenShift CRD compatibility

### Changed
- Template discovery consolidated into a single pass instead of cascading searches

## [1.0.2] - 2026-05-22

### Added
- Konflux CI/CD pipeline integration for container image builds

### Changed
- Bumped default OpenShift client version to 4.19.0

## [1.0.0] - 2026-05-21

### Added
- Initial release
- OpenShift template auto-discovery
- Remote template support via `TEMPLATE_NAME` environment variable
- Parameter file support via `PARAM_FILE` environment variable
- ArgoCD standard variables passthrough (`APP_NAME`, `APP_NAMESPACE`)
- Environment variable passthrough for template parameters
- `--ignore-unknown-parameters` for safe parameter handling
- Quoted replicas workaround
- Non-root container execution (UID 999)
