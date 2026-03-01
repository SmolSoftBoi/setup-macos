## ADDED Requirements

### Requirement: README one-liner shows canonical repository URL
The README SHALL include the canonical repository URL in its one-line summary beneath the title.

#### Scenario: Canonical URL appears in the one-liner
- **WHEN** a user reads the README introduction
- **THEN** they can see `https://github.com/SmolSoftBoi/setup-macos.git` in the one-line summary text

### Requirement: README install command clones canonical repository
The README installation command SHALL clone `https://github.com/SmolSoftBoi/setup-macos.git` and run the `setup` script from the cloned directory.

#### Scenario: User copies install command from README
- **WHEN** a user runs the documented install command
- **THEN** Git clones `SmolSoftBoi/setup-macos` into `~/.setup-macos`
- **AND** the command executes `~/.setup-macos/setup`
