## Global Guidelines *(Root `AGENTS.md`)*

This section outlines the universal conventions for the project. All code (shell scripts, configuration files, etc.) must adhere to these standards. Specific contexts may have additional rules (see subdirectory guidelines), but they do not override global rules unless explicitly stated.

### Code Style

* **Indentation & Formatting:** Use **2 spaces** per indentation level (no tabs) for all shell scripts and YAML files, following common style guides. Ensure files have no trailing whitespace and end with a single newline. Use an 80-120 character line length as a soft limit for readability.
* **Consistent Syntax:** Prefer modern, consistent syntax across scripts:

  * Use `$( ... )` for command substitution instead of backticks.
  * Always quote variable expansions and strings in scripts (e.g., `"$VAR"` to prevent word splitting).
  * Use lowercase for function and variable names (except constants which may be UPPERCASE). For config files, follow their expected case conventions.
* **Naming Conventions:** Name files and directories clearly. Script files should be **lowercase** and, if executable, may omit the `.sh` extension (the main `setup` script is an example). Configuration files should have descriptive names or standard names.
* **Comments:** Include comments to explain non-obvious logic, especially in shell scripts and complex workflow steps. Keep comments up-to-date when code changes. Avoid commented-out blocks of code in commits (remove unused code instead).
* **Lists and Data Files:** In list files (e.g., under `apps/` or `packages/`), put **one item per line** with no extra formatting. Maintain alphabetical order of entries for readability and to avoid duplicates (e.g., CLI tools and apps lists are sorted by name). The setup script skips lines starting with `#` and ignores anything following `#` on a line, so you may comment out apps or add inline notes. Blank lines are ignored as well.

### Build & Test

* **Shell Linting:** All shell scripts **must pass linting** with [ShellCheck](https://www.shellcheck.net). Integrate ShellCheck in the development workflow or CI to catch errors and style issues. Run `shellcheck` on each script after changes and fix any warnings or errors.
* **Code Formatting:** Enforce a consistent format using tools like **shfmt** for shell scripts. Use `shfmt -i 2 -ci -w` (2-space indent, indent case arms) to auto-format scripts. Agents should format code before committing. For YAML (GitHub workflows), maintain proper indentation and syntax (two spaces per level).
* **Workflow Validation:** Validate all GitHub Actions workflow files. Use **actionlint** (a static checker) to catch YAML syntax errors, invalid keys, or logic issues in workflows. This tool also runs ShellCheck on any shell commands in workflow steps, ensuring embedded scripts meet our standards.
* **Testing on macOS:** Because this project configures macOS systems, test changes in a macOS environment. For any update, at minimum:

  * Run the `setup` script on a macOS machine (or VM) and verify it completes without errors. Use a fresh or test user environment to see the full effect.
  * If fully automating the script run is difficult (due to interactive prompts), test critical sections individually. For example, confirm that each list of apps installs correctly by running those loop portions in isolation.
  * Ensure system changes (like defaults or settings) have taken effect as expected after script execution.
* **Continuous Integration:** The repo already includes `.github/workflows/ci.yml`, which runs a lint job on **macos-latest** for pushes to `main` and pull requests (`opened`, `synchronize`, `reopened`). It installs `shellcheck`, `shfmt`, and `actionlint` via Homebrew, then runs `shfmt -i 2 -ci -d .`, `shellcheck setup`, and `actionlint`. All CI checks must pass before merging. If an agent opens a pull request, it should include evidence of passing checks.
* **Example Commands:**

  * *Lint Shell:* `shellcheck setup scripts/my_new_script.sh` – verify no ShellCheck errors.
  * *Format Shell:* `shfmt -i 2 -ci -d .` – match CI formatting checks (use `shfmt -i 2 -ci -w .` to fix them).
  * *Validate Workflow:* `actionlint` – check all `.yml` files in .github/workflows for issues.
  * *Match CI Tool Install:* `brew install shellcheck shfmt actionlint` – install the local linting tools used by CI.
  * *Dry-Run Installs:* `brew install --dry-run <package>` – ensure a Homebrew formula or cask in the list is valid before adding.

### Environment Constraints

* **Target OS:** All code is written for **macOS** environments. Do not include Linux- or Windows-specific commands or paths. Assume the script is run on a modern macOS system with an administrator user account (standard users cannot use `sudo` by default).
* **Shell & Tools:** macOS uses Zsh as the default login shell (on recent versions). Always use a proper shebang in shell scripts. The system is used unless otherwise specified. Avoid using Bash-only features not supported in macOS’s default Bash version (3.2). For portability, prefer POSIX-compliant syntax when possible.
* **System Utilities:** Use macOS native utilities or ensure their availability via Homebrew:

  * Many BSD utilities (sed, grep, etc.) have slightly different flags than GNU versions. Agents should use options compatible with macOS defaults (for example, `sed -i '' …` for in-place edits, since macOS sed requires an extension). If a GNU-specific tool or option is needed, install the GNU version via Homebrew and call it explicitly (e.g., `gsed`) or adjust the script logic.
  * Do **not** assume common Linux packages (apt, dnf, etc.) are present – they are not on macOS. Likewise, avoid `bashisms` in `/bin/sh` scripts.
* **Homebrew Usage:** Homebrew is the core package manager for this setup:

  * Never run Homebrew with `sudo` – it’s not required and will error. The script should install Homebrew (if missing) using the official method and then run brew commands as a regular user.
  * If new system packages are needed, add them to the appropriate brew list (CLI, cask, etc.) rather than requiring manual install. Keep in mind Homebrew’s default prefixes: **Intel mac** uses `/usr/local`, **Apple Silicon** uses `/opt/homebrew`. Our scripts should handle both where applicable (e.g., using `/usr/bin/env` or brew’s installer which auto-detects).
* **Apple ID & App Store:** The setup uses `mas` (Mac App Store CLI) to install apps. Agents should remember that `mas` requires the user to be logged into the App Store. Do not assume a login; if an operation fails due to no login, the script should catch or inform the user. (At this time, the script does not explicitly check this, but future improvements should consider it.)
* **Internet Access:** The setup operations (Homebrew, mas, etc.) require internet connectivity. Agents could add checks or warnings if network is unreachable, but should not hang indefinitely. Use `curl -fsSL` with caution (as in the brew install command) to fail gracefully on network errors.
* **Filesystem:** The script may create or modify files in the user’s home directory (e.g., SSH keys, gitconfig, Mackup config). Always use `~` or `$HOME` to refer to the home directory, not hard-coded paths. Ensure file permissions are appropriate (e.g., `ssh-keygen` creates keys with correct perms). Avoid altering system files outside `/etc` or `/usr` unless necessary, and if so, always use `sudo` with user consent (as the script does for some `scutil` and `defaults` commands).

### Pull Requests & Commits

* **Commit Messages:** Follow a clear, consistent commit message style. Use imperative mood and present tense (e.g., "Add new brew package X", "Fix shellcheck warnings in setup script"). Start with a capital letter and keep the summary under \~72 characters if possible. Provide additional details in the description if the change is complex.
* **Pull Request Description:** When opening a PR (manual or via an agent), include:

  * A summary of what changes were made and why.
  * Confirmation that you (or the agent) tested the changes on macOS (including version info, e.g., "Tested on macOS 13.3") or ran relevant linters.
  * Any screenshots or logs of successful test runs or lint results, if applicable (for instance, showing that `shellcheck` passes, or that the workflow ran successfully in your fork).
  * Mention any related issue or task, if there's a tracking issue.
* **Templates:** If a PR template is provided in the repo, fill out all sections (testing steps, related issues, etc.). If not, still ensure the PR description covers the points above. For commits, if a conventional commit format is used (feat, fix, chore, etc.), apply it appropriately.
* **Review and Approval:** All code changes (especially those by AI agents) should be reviewed. The agent should request review from maintainers or ensure the change meets all guidelines before auto-merging. Large changes should be split into smaller PRs for easier review.
* **Changelogs/Documentation:** If the change impacts user-facing behavior (e.g., adding a new application to install, or a new config option), consider updating the README or documentation accordingly within the same PR.

### Forbidden & Discouraged Practices

* **Avoid Unnecessary `sudo`:** **Do not run entire scripts with `sudo`**, and avoid using `sudo` inside scripts unless absolutely required for a specific command. Follow the principle of least privilege – run as much as possible as a regular user. In this project, `sudo` is only used for commands that change system settings (e.g., writing to `/Library` or running Apple installers). Never use `sudo` for installing user-level packages (Homebrew, npm, etc.).
* **No Hard-Coded Secrets or Credentials:** Never store passwords, API keys, personal tokens, or any sensitive information in the repository. If authentication is needed (e.g., for the App Store or other services), it must be obtained from the user at runtime or configured securely via environment (for CI, use GitHub Secrets).
* **No Destructive Commands Without Confirmation:** Any command that could erase or override user data or settings should be done cautiously. For example, the script uses `defaults write` and other settings changes *only after user consent* (via prompt). Do not add commands like `rm -rf` on critical directories or disabling security features (Firewall, SIP) unless explicitly desired and approved. Always prompt the user or clearly comment such sections.
* **Don’t Ignore Errors:** All scripts should handle errors where possible. Do not blindly use `|| true` or similar to ignore command failures (unless part of a deliberate fallback mechanism). If a non-critical step fails, log a warning for the user. Critical failures should abort the process or at least be reported at the end.
* **No Outdated or Deprecated Methods:** Keep the installation methods up to date. For example, the Homebrew install command in use (Ruby script) should be updated if Homebrew changes their recommended approach. Avoid deprecated flags or commands (e.g., `brew cask` subcommand is deprecated in favor of `brew install --cask`, which we already use). Similarly, for GitHub Actions, don’t use deprecated features (like the old `set-env` or `add-path` commands that were removed).
* **Third-Party Code:** If incorporating any snippet from external sources, ensure it’s compatible with our license and attribute it in comments. (The current script gives credit to a GitHub user for inspiration – maintain this practice for any future borrowed code.)
* **Consistency Over Preference:** Agents should not introduce stylistic changes that conflict with established patterns unless aligning to a decided standard. For instance, don’t switch quote styles or indentation on a whim – only do so if it’s part of enforcing the stated guidelines. All changes should have a functional or clarity purpose, not just personal preference.
