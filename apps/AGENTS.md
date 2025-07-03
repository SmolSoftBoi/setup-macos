## Application Lists Guidelines *(apps/AGENTS.md)*

The **`apps/`** directory contains plain text lists of applications to install: Homebrew **CLI** apps (`apps/cli`), Homebrew **cask** apps (`apps/cask`), and **App Store** apps (`apps/app-store`). These files are read by the setup script to batch-install software. This section guides how to format and update these list files.

### Code Style

* **One Entry Per Line:** Each line in the list files should contain a single application identifier with no extra text. For example, in `apps/cli`, a line might be `wget`. Do not put multiple items on one line or any additional commentary on the same line.
* **Alphabetical Order:** Keep the entries in each list sorted alphabetically (by ASCII order). This makes it easier to spot duplicates and maintain consistency. For instance, the `apps/cli` list is sorted (a to z) and the `apps/cask` list is mostly alphabetical. If grouping related apps (see next point), sort within those groups.
* **Logical Grouping (Optional):** If there’s a need to group certain apps (e.g., all Adobe apps together as they are currently at the top of the cask list), that’s fine, but maintain alphabetical order within the group and consider adding a *comment line* above the group to label it. *However*, note that our script does not ignore comment lines by default, so any comment in these files would be read as an entry (and cause an install error). **Thus, by default do not include comments or blank lines** in these files. If grouping is needed for visual clarity, you may temporarily use comments while editing, but they must be removed (or the script updated to handle them) before commit. The safer approach is to just keep everything strictly sorted to avoid complications.
* **Correct Identifiers:** Use the exact package identifiers:

  * **Brew CLI formulas** (in `apps/cli`): Use the name as you would with `brew install`. E.g., `node`, `wget`, `php`. For formulas from core tap, the plain name is enough. If using formulas from other taps, specify fully (e.g., `homebrew/core/xxxxx` if needed, but Homebrew auto-taps core formulas so usually not needed).
  * **Brew Casks** (in `apps/cask`): Use the exact cask token (as on brew’s cask repository). E.g., `google-chrome`, `visual-studio-code` (these are typically lowercase and hyphenated). If a cask is in a special tap, include the tap in the name (as done with `homebrew/cask-drivers/philips-hue-sync` in the list). Ensure spelling is correct because a wrong cask name will cause the script to fail at that point.
  * **App Store IDs** (in `apps/app-store`): These must be numeric IDs (as found via `mas search` or in the App Store URL). Double-check the ID corresponds to the intended app. It’s helpful to include a comment in the commit message about which app an ID refers to, since the file itself is just numbers.
* **No Duplicates:** Do not add an application if it’s already listed in the same file or another list:

  * Check all lists to make sure you’re not adding a CLI formula that’s already being installed as a cask or vice versa. For example, do not list `firefox` in both `apps/cli` (as a formula) and `apps/cask` (as a cask). Generally, if a GUI app exists as a cask, use the cask (not the formula, if one even exists).
  * If a duplicate entry is found in a review, remove one. Duplicates would waste time and could confuse version management.
* **Case & Formatting:** All entries should be **lowercase** (Homebrew and mas are case-insensitive for names/IDs, but we keep consistency). No quotes or special characters other than those part of the official name (hyphens, slashes, periods if any). E.g., use `adobe-creative-cloud`, not `"Adobe Creative Cloud"` or other variations.
* **Trailing Newline:** Ensure each file ends with a newline character and no extra blank lines following it. (Some tools or editors ensure this; it’s good practice for version control.)
* **Example Layout:**
  *apps/cli:*

  ```
  git
  mackup
  nginx
  node
  ... 
  ```

  *apps/cask:*

  ```
  adobe-acrobat-reader
  adobe-creative-cloud
  adobe-creative-cloud-cleaner-tool
  airfoil
  ...
  ```

  *apps/app-store:*

  ```
  409183694
  1295203466
  ...
  ```

  Notice no annotations in the files themselves — they are pure lists.

### Build & Test

* **Verify Availability:** After adding a new entry to any list, verify that it’s a valid and available package:

  * For Homebrew CLI or cask: run `brew info <name>` or `brew search <name>` on a Mac to confirm the formula/cask exists and is named exactly that. If the package is new or from a non-core tap, run `brew install <name>` in isolation to see if brew prompts to tap something or errors. Adjust name or add tap if needed.
  * For Mac App Store IDs: run `mas info <ID>` or `mas install <ID>` on a test Mac. If you’re not signed in, `mas install` will fail, but it will at least tell you the app name it’s trying (or use `mas search <AppName>` to find the ID first). Double-check that the ID is correct and the app is available in your region (mas uses the account’s region). If an ID is wrong, the script will output an error like “No results found” for that ID.
* **Installation Test:** Ideally, test the addition by running the relevant part of the script:

  * If you added a brew formula to `apps/cli`, you can test by running `for app in $(<apps/cli); do brew install "$app"; done` on a Mac (or just run `./setup` and when it gets to "CLI Apps", confirm that it installs your new addition correctly).
  * If you added a cask, do similarly for casks: `for app in $(<apps/cask); do brew install --cask "$app"; done`. Watch for any license agreements or pop-ups (some casks like `java` or certain fonts might require user interaction – those are generally to be avoided or handled via flags if possible).
  * For App Store, if you have access, run `for app in $(<apps/app-store); do mas install $app; done`. If not signed in, mas will error. If signed in and you own the app (if it’s free, you can get it), it should install. If it’s paid and not purchased, mas will fail – which is something to consider (see “Forbidden” section).
* **Script Continuity:** Ensure that adding the new item doesn’t break the flow:

  * The script loops through these lists. If an install fails, our script *currently* doesn’t explicitly stop; it will print the command and proceed. However, a failing brew install might break out of the loop or prompt for input (for example, some casks require passwords or EULA confirmation).
  * Test scenario: adding a cask like `virtualbox` will succeed but leaves a system extension prompt. Adding a cask like `adoptopenjdk` might prompt for license (I think brew auto-accepts some). We have a special case for Adobe CC as it needed a separate run command. So if you add something similarly tricky, ensure to handle it.
  * If an issue is found (like the script hangs or errors at that item), consider addressing it: e.g., some casks might require `--no-quarantine` or other flags to install non-interactively. Ideally, choose software that installs cleanly.
* **Performance:** Be mindful when adding a large number of items:

  * Installing many apps will naturally take time. That’s expected. But try not to add redundant items. If two formulae can be replaced by one (for instance, if `node` includes `npm`, no need to list npm separately as a formula), avoid listing both.
  * If you add a group of new tools, test how long it roughly takes so the user isn’t left for hours. Usually, brew is okay, but App Store downloads can be slow for big apps (Xcode, etc.). For extremely large apps, consider if it’s wise to include by default.
* **CI Testing:** If using CI (GitHub Actions) to test installations, note that some apps cannot be installed in the CI environment (especially GUI apps/casks requiring user session). On a macOS runner, brew can install most casks headlessly, but some might fail. If our CI tries to run the full `setup`, it might encounter such issues. Keep an eye on CI results; if CI fails on a certain new app, that’s a red flag.

  * The agent might mark certain casks to skip in CI (for example, by conditionally not installing specific known-problematic ones if an environment variable `CI` is set). But that complicates the script. Prefer adding apps that install quietly. If a needed app is problematic, document it or handle it with a special case (like done for Adobe).
* **Deprecation Check:** When updating the lists, also check if existing entries are still valid:

  * Homebrew sometimes renames or deletes formulae (they might create aliases, but sometimes an install will warn "XYZ is deprecated, using ABC instead"). If you see such warnings, update the list entry to the new name.
  * Similarly for casks, if something moved tap or was split (e.g., some casks move to different repos), update accordingly.
  * App Store apps can disappear if the developer removes them. If an ID fails repeatedly, verify if the app is still on the store. If not, remove it from the list to avoid a hanging install attempt.
* **Example Testing Log:**
  After adding entry `firefox` to `apps/cask`, run `brew install --cask firefox`:

  * Expect: a success installation of Firefox cask.
    After adding ID `409201541` (Pages app) to `apps/app-store`, run `mas install 409201541`:
  * Expect: mas installs Pages (if not already) or says "already installed" if present. If not signed in or not purchased (Pages is free so just sign in needed), ensure to do that.
* **Rollback Plan:** If after merging, an issue is found with an item (e.g., it fails for many users), be ready to remove or fix that entry quickly. Agents should monitor issues or user reports.

### Environment

* **Platform Suitability:** Only include applications that run on macOS:

  * This might seem obvious, but ensure not to include any Linux-only or Windows-only tool in these lists. For instance, do not list `apt-get` or a Win32 app. Homebrew won’t have those anyway, and mas is only for Mac/iOS apps. But double-check that the tools are meant for macOS. (Homebrew core and cask repository are Mac-focused, so that’s a good filter.)
  * If an app is architecture-specific (e.g., some casks might not have an Apple Silicon build yet), brew usually handles that by installing under Rosetta or giving a warning. It’s good to be aware: e.g., `virtualbox` cask didn’t support Apple Silicon for a while. If such a case, maybe note it in documentation or avoid until supported.
* **Account Requirements:** Mac App Store items require an Apple ID with those apps. The environment assumption is the user has access:

  * Avoid adding paid apps by default, as not all users (or even the maintainer’s other machines) will have them. If you do include a paid app that you personally use, note that others running this script will hit an error unless they purchased it. It might be better to leave such apps out or make them optional.
  * For free apps, it’s generally fine as long as the user is logged in. E.g., adding Xcode (which is free) is okay, but Xcode is huge and maybe not desired for everyone. Use discretion.
* **Interactive Requirements:** Some brew casks open installers or require additional input (for example, `adobe-creative-cloud` which is why we handle it specially). The environment in which this script runs is an interactive user session (since it prompts), so it can pop up dialogs or GUI installers. That’s acceptable but not ideal to have too many of those:

  * Try to prefer casks that install quietly (most do). If an app has an installer package that always requires user clicks, maybe note it in the script (like "You will need to complete the installer for X manually").
  * The environment variable `CI` or similar could be used by brew to auto-accept licenses for some casks if set, but that's mostly for Xcode command line tools which we handle differently.
* **Disk Space & Network:** Each listed app will consume disk space and download bandwidth. On a fresh machine, the script could be installing dozens of apps. Ensure that list items are truly valuable for a standard setup:

  * Periodically review if any app is unnecessary or superseded by another. E.g., if `node` is installed, and later maybe we decide to use `nvm` instead, we’d remove one and add the other rather than keep both.
  * Keep in mind large packages (like Docker or Xcode) are tens of GB. If we include those, the user should expect it. It might be worth mentioning in README if the script will pull something huge.
* **System Modifications via Apps:** Some apps (especially casks) can change system settings or require specific macOS settings. For instance, installing kernel extensions or requiring permissions (like VirtualBox, or some VPN tools). After installation, those might need user approval in System Preferences. Our script notifies the user when tasks are done, but not specifically for those cases. If adding such apps, consider adding a note echoing something like "Note: after installation, you may need to grant permissions for X in System Settings."

  * Alternatively, avoid including apps that need heavy manual post-install configuration unless they are essential.
* **Homebrew Taps:** If adding an app from a non-default tap (like our example with `homebrew/cask-drivers` for Philips Hue Sync), know that brew auto-taps cask repositories on demand. But for obscure taps, you might need to explicitly run `brew tap <tapname>` in the script before installation. None of the current entries required an explicit tap because referencing `homebrew/cask-drivers/app` triggered brew to auto-add that tap.

  * If an agent adds a formula from, say, some developer’s custom tap, that’s probably not desirable unless necessary. Stick to official taps (homebrew/core, homebrew/cask, homebrew/cask-versions, etc.).
* **Global System State:** The list is static, but it influences system state when run:

  * If adding a background service (some brew formulae or casks install launch daemons, etc.), ensure it’s okay. For example, adding `nginx` (which we have) will install it but not start it by default (unless brew services is used, which we don’t in the script). That’s fine. But adding something like `mysql` formula might auto-start a service on install (brew these days doesn’t auto-start services unless you run `brew services start`). So installing it just puts the files. That’s okay.
  * Still, consider whether it makes sense to auto-install certain services. The user might not want something running. Maybe mention in documentation if a service is included (like "nginx will be installed (but not started) – run `brew services start nginx` if you want it to run on boot").
* **Maintenance:** The agent should occasionally update these lists:

  * Remove software that is no longer needed or has better alternatives.
  * Update names as mentioned.
  * Add new essential tools as the macOS development landscape evolves (for example, if a new package manager or language runtime becomes commonplace).
  * Ensure the list stays relevant to the intended use-case of this setup script (which seems to be a developer/designer’s machine setup, given the presence of apps like Adobe CC, code editors, etc.).

### Pull Requests & Commits

* **Describe Additions/Removals:** When proposing a change to these lists, the PR or commit message should clearly enumerate what is added or removed:

  * e.g., "Add Firefox, Slack to apps/cask, and mas ID for Slack (now on App Store) to apps/app-store. Remove deprecated Coda app." This helps reviewers quickly see the changes. Also mention why if not obvious ("Slack added to improve team communication setup" or "Coda removed because it’s outdated and replaced by Nova or VSCode").
* **Link to Software:** If adding a relatively unknown tool, it could be helpful in the PR description to include a link or a note about what it is. The maintainers might not recognize every name. For instance, "Add `shadowenv` (a directory-based environment tool) to CLI apps – this helps manage env variables per project."
* **Rationale:** Especially for larger apps or things that might be preference-based (like an editor or a browser), justify inclusion. The maintainer likely curated the list to their needs; an agent adding something should ensure it aligns with those needs:

  * Perhaps the maintainers use Chrome and Firefox, so adding Firefox is logical. But adding an obscure browser might not be.
  * If unsure, possibly open an issue first to discuss (though as an AI agent, directly PR with explanation might suffice).
* **Commit Granularity:** Group related additions in a single commit, but don’t mix unrelated changes. For example, if adding a few development CLI tools at once, that’s fine as one commit. But don’t lump a large set of disparate changes in one commit. This way, if one addition causes issues, it’s easier to revert that commit alone.
* **Testing Evidence:** It might be good to note in the PR that you tested the script with the new list items. For instance, "Tested installation of all new brew formulas and casks on macOS 13; all succeeded without errors. Mas installed the new apps after sign-in." Such notes reassure maintainers.
* **Update Documentation:** If the repository’s README or documentation lists the software it installs, update it to reflect your changes. (For example, if README has a section "This script will install: Homebrew, Git, Node, etc.", and you add a new major item, update that list).
* **Avoid Personal Bias:** As an agent, only add apps that are generally useful for the purpose of the setup script. Avoid adding something highly personal or niche unless you have evidence the maintainer would want it. It’s discouraged to bloat the list. When in doubt, err on not adding. If the maintainer specifically requests additions (maybe in an issue or so), then proceed.
* **Removal Impact:** When removing an app from the list, consider if it might affect users upgrading their setup:

  * Removing from the script doesn’t uninstall it from existing machines, it just won’t be installed on new runs. That’s fine typically. But if it was something critical (like removing `git` – which is critical but also comes with Xcode anyway), ensure it’s not breaking prerequisites.
  * Document removals in the changelog or PR so users know (e.g., "we no longer install XYZ by default").
* **Consistent Ordering in Diff:** Because we maintain alphabetical order, adding or removing items will naturally keep the list sorted. If you insert something out-of-order, the reviewer should catch it and request fix. The agent should double-check the order in the diff.
* **Prevent Merge Conflicts:** If multiple changes are happening to these lists in different PRs, there could be merge conflicts (because they are just sorted lines). The agent should be prepared to rebase and resolve conflicts, ensuring the final list is sorted and includes all intended entries once multiple PRs are merged.
* **Forbidden Entries (Policy):** In PRs, do not add:

  * Obviously illegal or pirated software.
  * Anything against company or team policy (if this is an internal setup script – seems personal though).
  * Duplicative entries as mentioned.
  * Paid software (unless the maintainer explicitly wants it and has a license – even then, they might not want to auto-install due to license prompts).
  * Very experimental or unstable tools – unless that’s the maintainer’s desire.
  * We should also avoid extremely resource-heavy additions (again, like Xcode, unless maintainers want that).
* **Review Focus:** Reviewers will likely check each new item:

  * They might verify if the names are correct (so do that homework).
  * They might ask "why add this?". The agent should be ready with reasoning.
  * They could also mention if something should rather be in a different list. For example, maybe an agent accidentally adds a CLI tool in cask list. That should be corrected.
  * They will check sorting, duplicates, etc., so agent should pre-empt those.

### Forbidden & Discouraged

* **No Comments in List Files:** As mentioned, don’t leave comments or blank lines in the committed lists. The script would attempt to read them. If a comment is absolutely needed for maintainers, consider updating the AGENTS.md or README rather than the list file itself. The list should remain machine-readable without issues.
* **Do Not Use Sudo in Lists:** (This might sound odd, but just to clarify) These files should only contain app identifiers. Don’t include commands or options (like `--head` or `--cask` or `sudo`). For example, do not put `sudo something` or `app --flag`. The script doesn’t expect that.
* **No Version Pins in Lists:** Don’t pin specific versions in these list files. For Homebrew, formula names generally shouldn’t include versions unless it’s a separate formula (like `python@3.9`). Use those versioned formula names only if necessary. Do not add something like `node@14` unless there’s a policy to stick to that version. In general, we want the latest stable versions.
* **Don’t Overcrowd Default Setup:** Avoid adding too many apps that not all users would want. The script is presumably for a primary user (the maintainer), so it reflects their needs. If you as an agent consider adding something big or debatable, maybe hold off unless there’s an indication it’s desired. (For instance, adding a second code editor or another similar tool might not be needed if one is already present).
* **No Manual Installation Steps:** If an application cannot be installed via brew or mas (for example, some apps are only on vendor websites), do not try to script downloading and installing it here unless absolutely necessary. This list should ideally contain only things installable through our automated package managers. If something is only obtainable manually, either skip it or see if a brew cask exists for it (often community casks exist for many apps).
* **Respect Licensing:** Some casks might install apps that require licenses. That’s usually fine (the app might open a license prompt on first run). But ensure that by installing it silently we are not violating any license terms. For instance, some software might require you to agree to EULA before even installing. Most brew casks handle this by printing a notice (or requiring `--no-quarantine` flags). As an agent, avoid hacks to bypass license agreements.
* **Keep Lists Focused:** Don’t merge categories. For example, don’t put Mac App Store IDs in the cask list or vice versa. Each list has a specific purpose and the script logic is separated. Messing that up would break installs.
* **No Post-Install in Lists:** Don’t try to embed any post-installation script into these files (like expecting the script to run something after install). If an app needs a post-install action, handle it in the main script logic, not in the list. The lists are purely data.
* **Avoid Redundant Tools:** As mentioned, if two tools do similar jobs, the list should ideally pick one to avoid confusion. For example, not installing two different package managers for the same language, unless the user explicitly wants both. Redundant entries just lengthen install and could conflict (e.g., two VPN clients).
* **Quality of Life:** The selection of apps should make sense for a macOS setup (productive, sensible defaults). Avoid anything known to be problematic (if a brew formula is notorious for causing issues, probably skip it).
* **Maintenance Burden:** Each new app is something to maintain. If an app rarely updates or is simple, fine. But if it’s something that frequently changes or could cause support burden, weigh the benefit. E.g., adding a complex database server might require configuration that the script doesn’t do, leaving user with an installed but unconfigured service. Unless we plan to configure it, maybe it’s not ideal to include by default.
