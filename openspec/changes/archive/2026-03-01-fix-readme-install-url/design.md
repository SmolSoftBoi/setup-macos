## Context

The README is the primary onboarding entry point for this repository. Its current install snippet clones a different GitHub repository (`EpicKris/setup-macos`), which can direct users away from the maintained source. The one-line summary below the title also does not establish the canonical repository URL.

## Goals / Non-Goals

**Goals:**
- Ensure README installation guidance always targets the canonical repository URL.
- Make the canonical repository URL explicit in the README one-liner.
- Keep the change documentation-only and low risk.

**Non-Goals:**
- Changing setup script behaviour or install flow beyond README text.
- Introducing new installation methods (Homebrew formula, curl pipe installer, etc.).
- Rewriting broader README content unrelated to source URL correctness.

## Decisions

Use the repository remote URL as the canonical source string: `https://github.com/SmolSoftBoi/setup-macos.git`.

Rationale:
- It matches `origin` and avoids ambiguity about which fork users should clone.
- It resolves the immediate install failure path caused by cloning a different repository.

Alternatives considered:
- Use a short URL without `.git`: rejected to keep the install command explicit and copy-paste ready.
- Keep the one-liner generic and update only the command: rejected because users should see the canonical source even before copying commands.

## Risks / Trade-offs

- [Canonical URL changes in future] -> Mitigation: keep README URL aligned with repository `origin` during release/maintenance updates.
- [Minimal doc churn only] -> Mitigation: scope intentionally narrow so behaviour and scripts remain stable.
