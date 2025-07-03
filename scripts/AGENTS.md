## Shell Scripts Guidelines *(scripts/AGENTS.md)*

This section extends the global standards with specifics for shell scripting in the **`scripts/`** directory (and any shell scripts in the repository, including the root `setup` script). It covers coding style, testing, and best practices unique to writing Bash/Zsh scripts for macOS.

### Code Style

* **Shebang & Shell:** All shell scripts should start with an appropriate shebang. To ensure the system finds in the PATH. If a script is intended to be POSIX-sh compatible, use `#!/bin/sh`, but note that on macOS `/bin/sh` is Bash in POSIX mode. Zsh-specific scripts should use `#!/usr/bin/env zsh` and be kept separate if needed.
* **Indentation & Brace Style:** Indent script code by 2 spaces per level (within if, loops, functions, etc.), matching the global style. Do not mix tabs and spaces. Place `then`/`do` on a new line (indented) or on the same line after a semicolon – choose one style and use it consistently (the existing script places `do` on the next line indented, which is acceptable). Example:

  ```bash
  if [ "$VAR" = "value" ]; then
    echo "Value set"
  fi
  ```

  or

  ```bash
  if [ "$VAR" = "value" ]
  then
    echo "Value set"
  fi
  ```

  The project currently favors the second style (newline before `then`), but consistency is more important than which style.
* **Function Declarations:** Define functions using the `fname()` syntax, not the legacy `function fname` form (to maintain portability and ShellCheck compliance). For example:

  ```bash
  cleanup() {
    echo "Cleaning up..."
    # ...
  }
  ```

  Use lowercase for function names. Group related functions together and consider adding a brief comment above complex functions to explain purpose.
* **Variable Usage:** Always quote variables unless you intentionally need word splitting or glob expansion. E.g., use `"$FILE"` instead of `$FILE`, especially in commands like `rm "$FILE"`. Use `${VAR}` braces when concatenating or to clarify boundaries (e.g., `"${DIR}/file.txt"`).
* **Tests and Conditionals:** Use `[[ ... ]]` for conditional tests in Bash (it’s safer for strings and avoids some quoting issues). Use `==` or `=~` inside `[[ ]]` for string matching and regex, respectively. For numeric comparisons, use `-eq, -gt, etc.` inside `[[ ]]` or use arithmetic `(( ... ))`. Always provide an **else/fi** or handle the negative case explicitly when it makes sense, so the script’s flow is clear.
* **Loops:** Prefer `while` and `for` loops with clear syntax. In for-loops iterating over file contents or command output, use `while read` loops or `for var in ...` carefully. For example, to iterate lines in a file: `while IFS= read -r line; do ...; done < file` is safer than `for line in $(<file); do ...; done` when dealing with complex data. *(In this project, simple lists are read with `$(<file)` which is acceptable since entries contain no whitespace. If that changes, adjust to a safer read loop.)*
* **Error Handling:** At the start of non-interactive scripts, consider using strict mode: `set -euo pipefail`. This will make the script exit on errors or undefined variables. **For interactive scripts** (like `setup`), `set -e` might be too aggressive since we want the script to continue even if one install fails. In those cases, handle errors manually:

  * Check exit codes and use conditional logic or `||` to display warnings. Example: `some_command || echo "Warning: some_command failed"`.
  * Use traps for cleanup if needed (e.g., trap EXIT to revert partial changes on failure).
* **ShellCheck Compliance:** Write code that passes ShellCheck without warnings. Common ShellCheck recommendations to follow:

  * Use `read -r` when reading user input or files to prevent backslash escapes from being interpreted (ShellCheck SC2162).
  * Quote variables and globs (SC2086, SC2068, etc.).
  * Don’t use deprecated or unsafe commands (`expr` for arithmetic, obsolete backticks, etc.).
    If a ShellCheck warning is a false positive or an intentional exception, you may suppress it with an inline comment, but include a justification. For example: `# shellcheck disable=SC2034  # VAR is used indirectly in command`.
* **Style Consistency:** Match the style of the existing `setup` script for things like echo output formatting, coloring, and prompts. The script uses helper functions (`header`, `step`, `run`, etc.) to standardize output. New scripts should follow a similar approach:

  * Use `echo` with escape codes for consistent formatting (e.g., `${INFO}`, `${SUCCESS}` colors defined in the script).
  * If adding new output styles, define them at the top of the script for reuse.
  * Follow the numbering scheme for chapters/steps if extending the main setup process.
* **File Executability:** Ensure any script in the `scripts/` directory (or the main `setup` script) is marked executable (`chmod +x`). Agents adding a new script should set the execute bit and use the correct line endings (LF, not CRLF).
* **Don’t Duplicate Logic:** If multiple scripts share functionality, consider abstracting it. For example, if we had several scripts needing to perform a common check, use a single script or function that all can call, rather than copying code. Place shared scripts or functions in a common location (like a `scripts/lib` folder) and source them. Always document this in the code comments so the agent knows where to find common functions.

### Build & Test

* **Local Testing:** Whenever a shell script is modified or added, test it locally on macOS:

  * Run the script with typical inputs in a controlled environment. For the interactive `setup` script, go through a full run (or as much as possible) to ensure new changes don’t break the flow.
  * If a script has different execution paths (e.g., user answers "Yes" vs "No"), test each path if feasible.
  * Use temporary files or dummy values as needed to simulate environment (for instance, you can create a dummy `~/.gitignore` to see if the script correctly skips creating one if it exists).
* **ShellCheck & Formatting Checks:** Before committing, run ShellCheck on all modified scripts and ensure 0 errors/warnings. Run `shfmt` to auto-format the code and ensure no formatting diffs. These steps can be automated in a git pre-commit hook or a CI job, but the agent/developer should also do it manually:

  * Example: `shellcheck scripts/*.sh` (adjust path to target new scripts).
  * Example: `shfmt -i 2 -ci -d scripts` to check formatting differences in the `scripts/` directory.
* **Automated Testing Harness:** Where possible, add tests for script functionality. For complex logic, consider using a framework like **BATS** (Bash Automated Testing System) to write unit tests for shell functions or small scripts. For example, if a script has a function to parse a value, you can extract it and test it with various inputs using BATS. (Writing extensive tests for an interactive script can be difficult, so focus on testable units or critical non-interactive pieces.)
* **Integration Testing via CI:** Use GitHub Actions to perform integration tests:

  * A CI job can run the `setup` script in a fresh macOS runner. One approach is to run it with non-interactive inputs. For example, one can pipe default answers: `yes N | ./setup` to answer "No" for all Y/N prompts (though note, this won't supply text for prompts that require a string like computer name, which might need a different strategy). Another approach is to temporarily modify the script in the CI environment to auto-fill answers (not ideal for production, but an agent could propose a `--noninteractive` flag in the future).
  * Even if full automation isn’t implemented, have a CI step to at least execute the script up to certain safe points or with dry-run options (e.g., skip actual installs, just check syntax and variable expansions). This ensures no syntax errors make it to `main` branch.
* **Example Test Scenarios:**

  * *Simulated Run:* Execute `./setup` on a macOS VM where nothing is installed and follow prompts to ensure it configures the system as expected. Verify each chapter completes.
  * *Section Test:* Run parts of the script manually: e.g., comment out everything except the "Install Apps & Packages" chapter and run that on a system that already has Homebrew, to test the loop logic for brew/mas installs.
  * *Error Simulation:* Temporarily modify an entry in `apps/cli` to an invalid package name and ensure the script handles the error gracefully (it should attempt and fail on that package but continue to the next, logging the error).
* **Performance Consideration:** If a new script or change significantly slows down execution (for example, adding a long loop or a heavy computation), test the runtime. The setup script runs a series of installations which naturally take time, but the script logic itself should be efficient. Avoid unnecessary subshells or external commands in loops (prefer built-in operations) to keep things smooth. If performance issues are detected, optimize or flag them in code comments for future improvement.

### Environment

* **macOS Shell Environment:** Scripts will be executed in the macOS default environment. On modern macOS, the default interactive shell is Zsh, but since our scripts specify Bash, they will run in Bash. Keep in mind:

  * The `$PATH` might differ between a non-interactive shell and an interactive Terminal session (especially for non-login shells). Our CI or automated runs might not have the same PATH as a user’s Terminal. If a script relies on a tool installed by Homebrew in `/usr/local/bin` or `/opt/homebrew/bin`, ensure that path is available. In scripts, you can explicitly call binaries with full path if needed (or adjust PATH within the script by exporting Homebrew’s bin path).
  * Environment variables like `HOME`, `USER`, etc., are available and should be used instead of hardcoding paths. For instance, use `$HOME` or `~` for the user’s home directory.
  * The locale on macOS might cause some commands to behave differently (e.g., BSD `date` vs GNU `date`). If using date, tar, etc., ensure the flags are compatible with macOS’s versions.
* **Dependencies and Tools:** The `setup` script installs Command Line Developer Tools (via `xcode-select --install`) and Homebrew early on. This means later parts of the script assume those tools are present (git, make, etc. from Dev Tools, and brew formulae from Homebrew).

  * If adding a script that runs very early (before Homebrew installation), do not call Homebrew or other non-base utilities in it. Stick to POSIX tools available on a fresh macOS (which includes curl, git (after Dev Tools), etc.).
  * If your script runs after Homebrew is set up, you can assume packages from our brew lists are available. For example, after the "CLI Apps" section, `wget` is installed and indeed the main script uses it. Keep such dependencies in mind – if a new script segment needs a tool, make sure the tool is installed by an earlier step or is native to macOS.
* **Interactive vs Non-interactive:** When writing scripts that may be used in both contexts, be aware of differences. Interactive scripts can use `read` to prompt the user. Non-interactive (like CI) will not have a TTY for `read`, causing it to hang. If you create scripts that might run in automation, provide a way to supply inputs via flags or environment variables to avoid `read`. For example, one could extend the main script to accept something like `-y` or `--defaults` to skip prompts. For now, any new prompt must default to asking the user; the agent should not add prompts that cannot be bypassed if we envision automated use.
* **macOS Version Differences:** Ensure scripts are compatible with supported macOS versions (likely macOS 11 Big Sur and above, since Big Sur introduced `macOS 11` as a version, and up to the latest, macOS 26+). Most defaults commands and Homebrew work across these, but occasionally some settings or paths might change:

  * For example, Apple Silicon vs Intel differences (as mentioned, Homebrew path). If a script references `/usr/local` explicitly, consider using the output of `brew --prefix` to adapt to `/opt/homebrew` on M1/M2.
  * If using `osascript` or other Apple-specific commands, check that they behave the same on newer macOS (Apple sometimes deprecates certain OSAX commands).
* **Resource Usage:** Be mindful of the environment’s resources. Mac CI runners, for example, have time and concurrency limits. If a script or command could hang or take excessively long, implement timeouts or checks. For instance, when running `softwareupdate -ia`, it could potentially hang if Apple’s servers are slow – currently the script runs it straightforwardly. An agent might consider adding a timeout or better feedback in the future.
* **Cleaning Up:** If a script creates temporary files, ensure they are cleaned up (e.g., trap EXIT to remove temp files or always remove them at end of script). Don’t leave stray artifacts on the user’s system. The main script mostly uses permanent changes, so this is more for any new utility scripts we might add.

### Pull Requests & Commits

* **Isolation of Script Changes:** If submitting a PR that modifies shell scripts, try to isolate those changes from unrelated changes. This makes it easier to review the script logic. For example, do not mix large refactoring of the script with adding a new app install; do one at a time with clear commits.
* **Detailing Script Changes:** In the PR description or commit message, **explain any script logic changes**. Shell scripts can be tricky, so note the intention:

  * e.g., "Use `trap` to ensure temporary files are deleted on exit, to handle interrupts."
  * e.g., "Added a check for internet connectivity before Homebrew installation, to fail fast if offline."
    If the change addresses a bug, describe the bug scenario and how the fix resolves it.
* **Testing Evidence:** Reviewers (or future maintainers) will benefit from evidence that the script works after your changes. Consider attaching:

  * Console output snippet showing the script running your new section successfully.
  * If you fixed a bug, show the before vs after behavior (e.g., "previously, if X was not installed, the script crashed; now it continues with a warning").
  * Indicate that ShellCheck was run and no issues remain (especially if your change was prompted by a ShellCheck finding).
* **Style Compliance in Commits:** If an agent auto-fixes style issues (like re-indenting or quoting variables), those changes should be in separate commits or at least clearly indicated. "Reformat script with shfmt" as one commit, and "Add feature X" as another. This separation helps reviewers see functional changes distinctly from stylistic ones.
* **Reviewing Workflow:** For shell script changes, a second pair of eyes is valuable. The agent should either get a maintainer’s approval or double-check logic thoroughly. Edge cases in shell can cause system-wide effects, so carefully consider potential side effects of each change (and mention these considerations in the PR if not immediately obvious).
* **Commit Example:**
  *feat(script): add check for Brew installation* – If brew is not installed, script now prompts and installs it. Tested on macOS 12 (no Homebrew) and macOS 13 (with Homebrew). ShellCheck passed.
  *style(script): quote variables and apply shfmt formatting* – Non-functional changes to meet style guidelines (no behavior changes).

### Forbidden & Discouraged (Shell Scripts)

* **Running as Root:** Do not require users to run the entire script with `sudo`. Our approach is to ask for elevation only for specific commands. If an agent encounters a scenario where a command fails due to permissions, handle it by using `sudo` for that command alone (with a clear reason). Never modify the script to suggest running it as root globally. This is both a security risk and against best practices.
* **Excessive Privilege or Changes:** Avoid making system modifications that are irreversible or too invasive. For instance:

  * Do not disable Gatekeeper, System Integrity Protection, or other security features as part of setup (unless the user explicitly wants that, which is outside the scope of a general setup).
  * Do not change user preferences without confirmation. The script currently asks before setting each macOS preference – maintain that pattern for any new settings an agent might add.
  * Avoid using `killall` or `launchctl` to force-restart services unless it’s necessary and the user has been informed.
* **Unsafe Command Use:** Be cautious with commands like `eval`. The `setup` script uses `eval $@` in the `run()` function to execute commands. This is acceptable for known safe input (since the script’s own code calls `run()` with controlled arguments). An agent should not introduce `eval` on user-provided input or other untrusted data. Similarly, avoid constructs that could lead to code injection (for example, constructing shell commands via string concatenation with unescaped input).
* **Slow Operations in Loops:** Do not place commands that call external processes inside tight loops if it can be avoided. For instance, calling `brew` or `defaults` repeatedly in a loop can be slow. It’s often better to batch operations if possible. If an agent adds functionality that needs to loop, ensure it’s efficient or the impact is negligible. (E.g., looping through 5 items is fine; looping through 1000 might need rethinking.)
* **Duplicate Entries:** When modifying the lists that the script processes (like `apps/cli`, etc.), ensure no duplicates are introduced by the script logic. The script currently doesn’t guard against duplicates in the lists – adding the same item twice would attempt to install twice. It’s the agent’s responsibility to avoid that. If for some reason a duplicate is needed (which is unlikely), handle it explicitly or comment why.
* **Bypassing User Input:** Do not remove or bypass user confirmations lightly. The interactive nature of the script is intentional to let users opt in/out of settings. If an agent automates something that was previously prompted, it must be justified (e.g., truly harmless default) and ideally still allow override. For example, don’t change a `[Y/N]` prompt to automatically proceed with "Yes" without a very good reason or alternate control.
* **Output Spam:** Avoid excessively verbose output in normal operation. The script uses pretty printing and minimal text per step. An agent shouldn’t add debugging info or large dumps of data to stdout in normal runs. Use verbose logs or debug flags for that purpose if needed. Keep the user-facing output clean and consistent with the current style (checkmarks, arrows, etc. as used in the script).
* **Legacy Compatibility:** While not exactly “forbidden,” note that supporting very old macOS versions or shells is not a goal. The agent shouldn’t try to add complex workarounds for outdated environments (e.g., macOS 10.10, or bash 2.x) unless asked. Focus on current systems.
