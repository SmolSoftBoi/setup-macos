## Why

The README installation command clones `EpicKris/setup-macos`, which is not this repository's canonical source and can send users to an outdated or incorrect fork. The quick-start copy also does not clearly point to the canonical repository URL.

## What Changes

- Update the README install command to clone the canonical repository URL and execute `setup` from that cloned directory.
- Replace the README one-liner under the title with the canonical repository URL so the primary source is explicit.
- Keep installation guidance concise while ensuring first-time users run commands against the correct repository.

## Capabilities

### New Capabilities
- `readme-install-guidance`: Define canonical-source requirements for README quick-start copy and install command examples.

### Modified Capabilities
- None.

## Impact

- Affected files: `README.md`.
- No runtime code, dependencies, or system configuration behaviour changes.
- Improves onboarding correctness by preventing installs from the wrong repository.
