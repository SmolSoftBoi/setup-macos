## GitHub Workflows Guidelines *(.github/workflows/AGENTS.md)*

*(If the repository does not yet have a `.github/workflows` directory, these guidelines apply to any GitHub Actions workflows that will be added to this project. The agent should create and maintain workflow files following these standards.)*

This section focuses on GitHub Actions workflow files, which are YAML files defining CI/CD pipelines in `.github/workflows/`. The Codex agent should ensure all workflows are well-formatted, valid, and serve their purpose without compromising security or efficiency.

### Code Style

* **YAML Formatting:** Use **2 spaces** for indentation in YAML (never tabs). All keys should be lowercase (GitHub syntax keys like `on`, `jobs`, `steps` are lowercase by requirement). Maintain a clean structure with line breaks and indentation exactly as needed by the YAML specification.

  * Ensure lists are properly indented under their parent key (e.g., steps under jobs, uses under with, etc.). Misaligned indentation can break the workflow.
  * Example:

    ```yaml
    jobs:
      build:
        runs-on: macos-latest
        steps:
          - name: Checkout code
            uses: actions/checkout@v3
          - name: Run setup script
            run: ./setup
    ```

    This shows correct indentation for keys and list items.
* **Descriptive Names:** Use the `name:` field to label workflows and steps clearly:

  * The workflow YAML should have a top-level `name: CI` (or something descriptive like "Setup macOS CI") if not provided, to identify it in the Actions tab.
  * Each job should have a `name` if multiple jobs exist (though one job workflows can skip it or just rely on the job key).
  * Each step should have a `name` unless the step is self-explanatory from the `uses` or `run` command. For instance, prefer:

    ```yaml
    - name: Install Homebrew packages
      run: brew install shellcheck shfmt
    ```

    over a blank or unclear step. This makes the action log easier to follow.
* **Order and Organization:** Organize workflow files logically:

  * Keep related steps together. E.g., have all setup steps (checkout, environment setup) at the beginning, then testing steps, then deployment (if any) at the end.
  * Use comments to separate sections if the file is long (YAML supports comments with `#`).
  * If there are multiple workflows (e.g., one for CI tests, another for releases), ensure they are separated into different YAML files with appropriate names (like `ci.yml`, `release.yml`). Don’t overload one workflow with unrelated tasks.
* **Reusability and Matrix:** If a workflow can benefit from a matrix (testing multiple versions, multiple configurations), define a matrix strategy in a clean way. Use newline for each matrix entry for readability:

  ```yaml
  strategy:
    matrix:
      os: [macos-latest, ubuntu-latest]
      node: [14, 16]
  ```

  If not needed, keep things simple with a single runner.
* **Action Version Pinning:** Always pin actions to a specific version or tag. For official actions like `actions/checkout`, use the major version tag (e.g., `@v3`). For third-party actions, it’s even better to pin to a full length commit SHA for security (to prevent supply chain issues). For example:

  ```yaml
  - uses: some/action@v1.2.3
  ```

  or if high security needed:

  ```yaml
  - uses: some/action@c1a2b3c4d5e6f7890 (specific commit)
  ```

  This prevents unexpected changes if the action’s latest version updates.
* **Secrets and Sensitive Data:** Do not hard-code any sensitive values in the workflow. Use GitHub Secrets for things like tokens or passwords. Reference them as `${{ secrets.MY_SECRET }}`. **Never print secrets** in logs (avoid `echo $SECRET`). If a step uses a secret, ensure that step does not have `run:` commands that inadvertently leak it (e.g., in debug output).
* **Environment Variables:** Use `env:` at the job or step level to define any environment variables needed by multiple steps. This avoids repetition and keeps values consistent. For example, if multiple steps need `HOMEBREW_NO_AUTO_UPDATE: 1`, set it once at job level under `env`.
* **Naming Conventions:** Name workflow files with lowercase and hyphens (e.g., `ci.yml`, `release-build.yml`). The file name isn’t critical to functionality but keeping it lowercase and meaningful helps maintainers. Inside the file, you can use a nice `name:` for display. Our style: small and focused workflows.
* **Workflow Triggers (`on`):** Be explicit with triggers:

  * Use `on: push` with specific branches if appropriate (e.g., `branches: [ main ]` to only run CI on the main branch pushes, plus PRs).
  * Use `on: pull_request` for PR validation. Include `paths` or filters to avoid running on changes that don't affect the project, if needed (though for this repo, probably run on all changes because any change could potentially affect the setup).
  * If using scheduled or manual triggers, define them clearly and ensure they serve a purpose (e.g., a schedule to run weekly could catch bit-rot in the script if brew or mas environment changes).
  * Avoid overly broad triggers that could cause unwanted runs (for example, `push: branches: ['*']` including gh-pages or docs changes if not needed).

### Build & Test

* **Linting Workflows:** Before committing a workflow, use **actionlint** to check it. This static analyzer will catch:

  * YAML syntax issues.
  * Invalid or missing fields in the Actions syntax.
  * References to undefined secrets or invalid uses of expressions.
  * Even checks like ShellCheck on inline `run` scripts and security no-nos (it can warn if you use unsafe commands with secrets, etc.).
    Run `actionlint .github/workflows/your_workflow.yml` locally, or have an agent run it, to ensure no errors. This is a crucial step since a broken YAML will result in GitHub ignoring the workflow silently or showing a config error.
* **Local Testing with `act`:** Consider using the [`act`](https://github.com/nektos/act) tool to run GitHub Actions locally for testing. While not a perfect emulation, it can catch obvious issues and let you iterate faster for simple workflows. For example, `act -j build` would run the `build` job locally (though note that macOS jobs can’t run on a non-macOS machine with `act`; you can test general logic on Ubuntu though).
* **CI Behavior:** Ensure that the workflow achieves the intended test coverage:

  * We likely want a CI workflow that runs on PRs to lint the scripts (ShellCheck, shfmt) and perhaps even run the `setup` script in a macOS runner. Make sure to include steps for each:

    * Checkout code (`actions/checkout`).
    * Set up environment (for example, install ShellCheck or shfmt if not present on macOS runner: note macOS runners do have brew, so you can `brew install shellcheck shfmt` within the job).
    * Run ShellCheck on scripts and fail if issues found.
    * Run shfmt in diff mode to ensure formatting is correct (fail if not).
    * Possibly run the `setup` script with flags or dummy input as discussed.
  * If any step fails (exits with non-zero), the job should fail. Don’t mask failures. For example, if you use `|| true` in a run step for some reason, be aware that it will prevent the job from failing even if the command failed.
  * Use `continue-on-error: false` (default) for most steps. Only use `continue-on-error: true` for non-critical tests that should not block a merge (rarely needed).
* **Test Matrix (if applicable):** If we decide to test on multiple macOS versions (GitHub might offer `macos-12`, `macos-13` labels, etc.), set up a matrix for that. Ensure the workflow is efficient – maybe limit to one macOS version if matrix becomes too slow or uses too many runner minutes, unless it's important. Since this repo is specifically for macOS, testing on one latest version is usually okay, but keep an eye when macOS updates (like when macos-14 arrives, ensure compatibility).
* **Artifacts and Logs:** If a workflow produces useful artifacts (like log files, or test result files), use the `actions/upload-artifact` to store them. For example, if running the setup script in CI, capturing its output log and uploading could help debug failures. Name artifacts clearly (e.g., `setup-log.txt`). However, avoid uploading large or unnecessary files (like the entire Homebrew cache or node\_modules – unless needed for caching which is separate).
* **Caching in CI:** Use caching wisely to speed up workflows:

  * For example, caching Homebrew downloads or installed packages might not be straightforward on GitHub’s mac runners due to permissions. But you could cache things like `~/.npm` if node is involved, or `~/Library/Caches/Homebrew` to avoid re-downloading bottles.
  * Use `actions/cache` with a good key (for instance, key on OS version + brewfile checksum if we had one). But ensure cache restore/save steps don't conflict with our script. If our script always does `brew update`, that’s fine, but we could skip it if we trust cache (though probably still do update).
  * Remember to add `if: steps.<step>.outputs.cache-hit != 'true'` in cases where you want to conditionally run installs only when cache not hit.
* **Example Workflow Testing:**
  After writing a new workflow file (say `ci.yml`), do the following:

  * Run `actionlint ci.yml` locally to ensure no lint errors.
  * Push the workflow to a test branch (or use GitHub’s workflow editor’s `dry-run` if available) to see if it appears in Actions. Fix any syntax issues if the workflow fails to trigger (often due to indentation or bad `on` syntax).
  * If the workflow runs but fails in steps, examine the log. For instance, if the `setup` script fails on CI because it’s waiting for input, that indicates you need to adjust how it’s run in CI (maybe provide inputs or flags). Update the workflow accordingly.
  * Once the workflow passes on the test branch, you can be confident in merging it to main.
* **Monitoring:** It’s a good practice to occasionally review the workflow runs on the repository (in the Actions tab) to catch any intermittent failures or needed updates. For example, if Homebrew outputs a warning or a new macOS runner image changes something (like a tool version), ensure the workflow still works. Agents can proactively update the workflows if, say, ShellCheck gets updated and now flags new things – update the script or suppression rules as needed so CI remains green.
* **actionlint Integration in CI:** You might also consider adding a step in the CI workflow that runs `actionlint` on the workflows themselves, to ensure future changes by others are also caught (kind of meta!). This could be part of a linter job.

### Environment

* **GitHub Runner Choice:** Use the appropriate runner for each job:

  * For testing the macOS setup script, use `runs-on: macos-latest`. This provides a macOS environment with Homebrew (usually) pre-installed and some common tools. Note that macOS runners are slower and limited in concurrency, so keep the jobs minimal.
  * If a job doesn’t need macOS (say, just linting shell scripts), you can use a Linux runner (`ubuntu-latest`) which is faster and unlimited for public repos. For example, a job that only runs ShellCheck can run on Ubuntu since ShellCheck can lint bash scripts without needing macOS. This can save macOS minutes. However, ensure consistency: if there’s any chance the shell script behaves differently on macOS (e.g., path differences), you might still want to test on macOS. A balance can be: do linting on ubuntu, and a full run on macos.
  * For any job installing packages or running GUIs (not likely here), macOS might be needed. Windows runner is likely not needed at all for this repo.
* **Software on Runners:** Understand the default tools on GitHub runners:

  * macOS runners come with a lot of developer tools preinstalled (Xcode, brew, etc.). Check [GitHub’s documentation](https://github.com/actions/virtual-environments) for what’s available. Use what’s there rather than reinstalling. E.g., if Python is needed for some reason, it’s already on the runner, no need to brew install it.
  * If our workflow uses Homebrew, be mindful that running brew as GitHub Actions user is fine (they have passwordless sudo if needed, but brew doesn’t require sudo). You might want to add `brew update` at start if you rely on brew formulas (though our script itself does `brew update` anyway).
  * Node and npm are also on the runner by default, but maybe not the latest. If testing npm global packages, we might install Node via `actions/setup-node` to ensure a certain version. Our script installs Node via brew, which we might not want to do in CI since it’s slow – instead, could use `setup-node` to have Node ready, then maybe skip the brew install of Node in CI by faking that step or it will detect Node exists.
* **Secrets and Permissions:** Check repository settings for required secrets if workflows need them. For this repo, likely not using secrets (since we’re just testing installation). But if in future we add, say, a workflow to release a package or something, we’d store tokens as secrets.

  * In workflows, use the new `permissions:` field at job or workflow level to restrict GITHUB\_TOKEN permissions. By default it’s `read-all`, which is fine for CI. If the workflow ever needs to create releases or commit code, you’d bump specific permissions (like contents: write). The agent should keep principle of least privilege: e.g., for a pure test workflow, you can explicitly set:

    ```yaml
    permissions:
      contents: read
    ```

    to make it clear it’s not doing any writing to repo.
* **Caching Environment:** When using cache, ensure that environment differences are accounted for in the cache key. For instance, if caching Homebrew, key by macOS version since caches might not be compatible across OS versions (and Homebrew’s installed package binaries differ for ARM vs Intel, though GH mac runners are currently Intel only, that could change).

  * Similarly, if caching `~/.npm`, include something like `node-version` in the key (if matrix has node versions).
* **Parallelism and Limits:** GitHub Actions on macOS can be slower to start and have fewer concurrent jobs allowed. Try not to run too many macOS jobs in parallel. If matrix is large, consider if all combinations are necessary. The agent can serially run some steps if needed.

  * E.g., maybe run shellcheck on ubuntu concurrently while the macOS job runs the full script, to cut overall time.
* **Workflow Maintenance:** The agent should periodically update workflows:

  * Bump action versions (e.g., `actions/checkout@v3` is current; if v4 comes out and is stable, update it).
  * Remove or modify steps that become unnecessary (for instance, if macOS runners eventually include ShellCheck by default, we could skip installing it).
  * Adapt to changes in the project (if new scripts added, ensure CI picks them up in linting; if new config or features, maybe add test steps).
  * Watch for deprecation notices from GitHub (they often announce deprecations in advance – e.g., ubuntu-18.04 was removed, etc.). Agents should update the runner labels as needed (e.g., if `macos-11` is deprecated in favor of `macos-12`, etc.).

### Pull Requests & Commits

* **Workflow Changes PR:** Treat workflow changes as carefully as code changes:

  * In commit messages, clearly state what’s being changed in the workflow and why. e.g., "Add CI workflow for ShellCheck and run setup script on macOS runner" or "Fix CI: update action versions and add cache for brew".
  * Mention any new steps or checks introduced. For example, "This adds a step to run ShellCheck on all shell scripts, addressing issue #X".
  * If the workflow is expected to fail until a certain issue is fixed, mention that (though typically you’d fix the issue in the same PR).
* **Testing Plan in PR:** For workflows, you often can’t fully test them until they run on GitHub. But you can simulate or use a fork. In the PR description, an agent can note "Tested the workflow on my fork \[if applicable] and it passes." or "Will monitor the first run on main to ensure it behaves as expected." This communicates diligence.
* **Keep Workflow Changes Separate:** Where possible, separate CI workflow changes from other changes. For instance, if you are fixing a script bug and also adding a CI workflow, consider doing one, merging, then the other, or at least separate commits. This way, if the workflow fails initially, it’s easier to iterate on it without holding up unrelated code changes (or vice versa).
* **Security Reviews:** Workflow changes should undergo a quick security sanity check in PR:

  * Ensure no secrets are echoed or logged.
  * Ensure that if PRs from forks run the workflow, they don’t have access to things they shouldn’t. (By default, GitHub doesn’t give forked PRs access to repository secrets, which is good. If our workflow needs secrets, use `pull_request_target` carefully or find alternatives.)
  * The agent or reviewer should confirm that any third-party actions used are reputable and pinned (as discussed). If a new action is introduced, maybe note why that action is needed and confirm it’s a well-used one.
* **Iterating on Workflows:** It’s common that a workflow might need a few fixes after initial PR (due to environment quirks). The agent should be responsive in adjusting it. It might be useful to allow failing fast on non-critical steps initially (mark as optional) just to get feedback. But ultimately, the goal is a reliable, required-check workflow.
* **Comments in Workflow Files:** Encouraged to include comments in the YAML to clarify tricky parts. These comments won’t show up in the Actions UI but help future maintainers. For example:

  ```yaml
  - name: Install brew packages
    run: |
      brew install shellcheck shfmt
      # Installing ShellCheck and shfmt to lint shell scripts
  ```

  Or at top of file, `# Workflow to test shell scripts and configuration on macOS`.
  When making changes, update comments if they become outdated (e.g., if we remove a step but the comment still mentions it, fix that).
* **Forbidden Patterns in PR (Workflows):**

  * **Do not** disable required checks without reason. For example, don’t remove a workflow or mark it `continue-on-error: true` just to get a green build if it’s actually catching a real problem. Instead, fix the underlying issue.
  * **Do not** commit GitHub tokens or credentials. This is repeating the secret rule: if a maintainer accidentally reviews and sees a secret in a PR by an agent, they’ll have to invalidate it and it’s a serious security mishap.
  * **Avoid workflows that auto-merge or auto-deploy without review** unless that is explicitly desired and configured. For now, any deployment or changes to user systems via Actions should be manual or carefully gated.
  * **No long-lived polling or heavy scripts in CI** – Workflows should finish reasonably. If an agent introduces a step that waits excessively (maybe waiting for an external event) or runs an infinite loop, that’s not acceptable. Also, avoid too chatty workflows (commenting on PRs for every run, etc., unless needed).

### Forbidden & Discouraged

* **Don’t Expose Secrets:** (Worth stating again) Never write something like `echo "$SUPER_SECRET"` in a workflow. Even for debugging, this is forbidden. Use secure logging or omit entirely.
* **No Unsanctioned Third-Party Actions:** Only use third-party actions that are necessary and widely trusted. For example, `actions/checkout`, `actions/cache` are official. If you need a specific tool, check if GitHub provides it or install via script. Bringing in a random action from the marketplace can introduce risk. If an action is used, it should be pinned to a version and ideally the source should be inspected or known.
* **Self-Hosted Runners:** Don’t create workflows requiring self-hosted runners unless the project maintainers plan to provide one. All our workflows should run on GitHub-hosted runners (`ubuntu-*`, `macos-*`). A PR from an agent trying to use a self-hosted runner will not run and is not useful here.
* **Limiting Permissions:** As mentioned, do not give the workflow excessive permissions. For instance, don’t use `actions/setup-go` or similar to install random things unless needed. Keep the workflow lean.
* **No Email/Slack Notifications in Workflow:** Unless requested, do not add steps to send messages or notifications from the workflow. GitHub already handles notifying on PR statuses. Additional notification steps can expose info and complicate things. Such steps often require secrets (like a Slack webhook) which we may not have or want to maintain.
* **Avoid Cron Triggers that Spam:** A cron (`schedule:`) trigger is discouraged unless there’s a clear maintenance reason (like regular dependency updates). If added, it should be infrequent (e.g., weekly or monthly) and only if maintainers want it. Unneeded scheduled runs waste CI resources.
* **No Deployment to User Machines:** Ensure workflows do not attempt to run code on any machine other than the GitHub runner. For example, do not incorporate something that SSH’s into the user’s Mac; that’s outside the scope. All Actions should be contained in the CI environment.
* **Workflow Naming:** Don’t use confusing names. E.g., don’t name a workflow "Main" – name it for what it does. Also avoid duplicate names which could confuse (like two jobs both named "Build" – differentiate them if they do different things).
* **Commented-Out Code:** Remove any leftover snippets or experiments in the YAML. For instance, if while testing you had a step commented out, either remove it or uncomment if needed. Clean final workflow files are expected – agents shouldn’t leave debug clutter.
