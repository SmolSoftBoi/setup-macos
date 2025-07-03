## Configuration Files Guidelines *(configs/AGENTS.md)*

This section provides rules for configuration files stored under the **`configs/`** directory (and any other config files in the repo). Currently, this includes files like `mackup.cfg` and could extend to any dotfiles or settings templates in the future. These guidelines ensure configs are consistent, safe, and effective.

### Code Style

* **Format & Syntax:** Follow the syntax rules of the respective configuration format:

  * For **INI-style** configs (like `mackup.cfg`), use clear section headers in square brackets (e.g., `[storage]`) and key-value pairs in the form `key = value`. Maintain a consistent style with one space before and after the `=` sign, as shown in our Mackup config.
  * If new config files are **YAML**, **JSON**, or other formats, adhere to their standard formatting (e.g., 2-space indent for YAML, keys in JSON quoted, etc.). Always produce valid syntax (use linters or formatters if available: `yamllint` for YAML, `jq` or similar for JSON).
* **Alphabetical Order (if applicable):** Within config sections, consider ordering keys alphabetically unless the semantics require a specific order. For Mackup’s config, order isn’t crucial (it only has one key), but if multiple entries (e.g., lists of applications to ignore), sort them for readability.
* **Comments:** Use comments in config files sparingly and only if the config format supports it:

  * INI files often support `;` or `#` for comments. If adding commentary, prefix with `;` (to avoid confusion with `#` used in shell). For example:

    ```ini
    [section]
    ; This is a comment explaining the following setting
    setting_name = true
    ```
  * Do not include comments that the target application might misinterpret. Always verify that comments don’t break the config parsing.
  * If a config file is very short (like our `mackup.cfg`), comments may not be necessary at all. Instead, rely on documentation in AGENTS.md or README for context.
* **No Trailing Spaces:** Ensure there are no trailing spaces at end of lines in config files. Some programs are sensitive to whitespace. Our style is to keep configs trimmed and clean.
* **File Encoding:** All config files should be UTF-8 encoded without BOM. This is usually standard, but just ensure not to include special Unicode characters unless needed (and if so, document them).
* **Example Values:** If adding template config files (for example, a sample `.env` file or a dotfile template), provide example values or placeholders rather than real values. E.g., `API_KEY = "<your-api-key-here>"`. This helps users know what to do while keeping the repo free of secrets.

### Build & Test

* **Validate Config Syntax:** After editing or adding a config file, test it with the application that uses it.

  * For **Mackup (`mackup.cfg`)**: Run `mackup backup` or `mackup restore` and ensure it does not error out. Mackup will read `~/.mackup.cfg` (which our script copies from `configs/mackup.cfg`). Ensure that after copying, Mackup recognizes the settings. For example, our current config sets `engine = icloud`; verify that Mackup is indeed using iCloud (check that it creates an `~/Library/Mobile Documents/com~apple~CloudDocs/Mackup` folder or similar).
  * If a config is for an application (say we add a config for an app), launch or run that application in a test scenario to confirm it accepts the config. For instance, if in future we include a config for a text editor, start the editor and ensure no errors, and that settings apply.
  * Use available validation tools: for JSON, run it through `jq . config.json` to ensure it’s valid JSON. For YAML, use `yamllint config.yaml`. Many config formats have linters or at least the program itself can do a dry-run with the config.
* **Integration in Script:** If the config file is deployed by the setup script (like copying to a location), test that part of the script. In our case:

  * Ensure the script successfully copies `configs/mackup.cfg` to `~/.mackup.cfg`. After running the script, check that the file exists in the home directory and matches the repository version.
  * If the agent adds another config deployment step (e.g., copying a template .zshrc), test that the file is copied and that no existing user file is overwritten without caution. Perhaps the script should back up any file it replaces (the Mackup step doesn’t check for existing `~/.mackup.cfg` but uses `-f` to force; in that case, we assume either the user didn’t have one or is okay replacing it).
* **Backwards Compatibility:** If modifying a config file that was already in use, consider the impact:

  * For example, if we change the Mackup storage engine from iCloud to Dropbox, a user who runs the script again might have their backup move locations. Such a change should be tested thoroughly (and ideally communicated).
  * Test scenario: if a user had a previous version with different config, what happens when applying the new config? Ensure it doesn’t corrupt or conflict. Possibly include migration steps if needed.
* **Multiple Environments:** If possible, test config usage on multiple macOS versions or setups. For instance, ensure Mackup with iCloud works on both Intel and Apple Silicon Macs (should be fine), or that any path references are valid on different setups (the iCloud path is standardized by Apple, but if an app’s config path differs by OS version, handle accordingly).
* **Example Testing Steps:**

  * *Mackup Config:* After running the script, open Terminal and type `mackup backup`. Expect to see it using iCloud (no errors about engine). Alternatively, inspect `~/.mackup.cfg` and manually run `mackup backup --dry-run` to see what it would do.
  * *Future Config (hypothetical):* If we add a `gitconfig` template, after script runs, do `git config --global -l` to ensure settings from the template took effect.

### Environment

* **MacOS Specific Paths:** Configuration files often contain file paths or platform-specific values. Make sure these align with macOS conventions:

  * In `mackup.cfg`, the storage engine `icloud` is specific to macOS because it relies on iCloud Drive. This is fine since our environment is macOS. If adding configurations that reference directories, prefer using `~` (HOME) or environment variables that will be correctly set on macOS.
  * If a config file might be used on other OS as well (for example, if a user shares dotfiles between macOS and Linux), consider that in the content. Since this project is macOS-focused, it’s acceptable that configs are macOS-tailored, but avoid outright breaking other platforms if a user syncs the config elsewhere. (Mackup is multi-platform; specifying `engine = icloud` will just not apply on systems without iCloud, which is okay.)
* **No Personal Data:** Configuration files should not include personal identifiable information specific to the maintainer or any user. For example, do not hard-code a specific username, email, or license key in a config. The Mackup config uses only generic terms. If we were to include a sample SSH config, it should use placeholders (e.g., `User your_username` not a real username).

  * If there’s a need for personal data (like an email in `.gitconfig`), the script should prompt the user rather than the config file containing it. (Our script indeed prompts for name and email and then writes to git config, rather than storing them in the repo.)
* **Upstream Compatibility:** Many config files correspond to external tools (Mackup, Git, etc.). Always check the documentation of the tool for any constraints:

  * For Mackup, ensure that any keys we put in `mackup.cfg` are supported keys. (For instance, `engine = icloud` is from Mackup’s docs to use iCloud Drive as backend).
  * If adding new config for another tool, adhere to that tool’s config format and recommended practices. E.g., if adding a config for a hypothetical app, don’t deviate from how that app expects the config.
* **File Locations:** The setup script often copies config files to the user’s home directory (like `~/.mackup.cfg`). Ensure that the destination and usage of each config is correct:

  * If adding a config for an app, confirm where that app expects the file (in home dir, in `~/Library/Preferences`, etc.). The agent should create or deploy the file to the right path. Always use `$HOME` to construct such paths in the script.
  * Ensure the script creates necessary directories. In our example, before copying `mackup.cfg`, the script creates `~/Library/Mobile Documents/com~apple~CloudDocs/Configs/Atom` and `~/.atom` directories (likely because Mackup will restore Atom configs there). This implies knowledge of Mackup behavior. If adding a config for a new tool, also create any required directory structure so that when the tool runs, it finds everything in place.
* **Future Configs:** If additional configuration files are added (for instance, a global `.gitignore` template, a VSCode settings file, etc.), consider the environment interactions:

  * Some configs might be sensitive to OS (for example, a preferences plist). In such cases, ensure to only apply on macOS or that the config doesn’t break if synced elsewhere.
  * Consider optional vs default: perhaps not every user will want every config. If adding something potentially optional (like a specific app config), you might want to gate it behind a prompt in the script ("Do you want to configure X?"). The config guidelines would then note that the file is only applied if user opted in.
* **Testing with Different Users:** If possible, test applying config files on a fresh user account or a different Mac user to ensure that nothing assumption-specific (like a username embedded) is present. Everything should be relative to the current user running the script.

### Pull Requests & Commits

* **Describe Config Changes:** When proposing changes to configuration files, clearly describe what’s being changed and why:

  * For example, “Switch Mackup backup engine from Dropbox to iCloud to utilize iCloud Drive for storage” – and perhaps note the benefits or reasons (e.g., “since all users of this script have iCloud by default”).
  * If adding a new config file, explain its purpose. E.g., “Add global .gitignore for macOS and common development artifacts” and list some contents or why it’s helpful.
* **Document Impact:** If a config change could impact the user’s environment, mention it. e.g., “This will reset any existing Mackup config to use iCloud, so existing backups on other engines will need to be migrated.” This helps maintainers evaluate if the change is acceptable.
* **Keep Config Changes Atomic:** Separate unrelated config changes into different commits or PRs. For instance, updating Mackup config and adding a new Zsh config in one PR might be okay if they’re under a “configs” umbrella, but make sure each commit is focused. This way, if something needs to be reverted, it’s easier.
* **Testing Evidence:** Just like with scripts, provide evidence of testing if applicable. If you changed a config and then ran the tool (Mackup, etc.), mention “After this change, running `mackup restore` successfully pulled configs from iCloud (log attached in comments).” This builds confidence in the PR.
* **Respect Upstream Defaults:** If possible, avoid diverging heavily from upstream defaults in config files without reason. For example, if Mackup’s default engine was Dropbox and we change it to iCloud, that’s a conscious choice. We should avoid arbitrary changes that aren’t well-justified (like changing retention policies or adding obscure settings) – unless they solve a known issue or are commonly recommended. In PR discussions, one might reference upstream docs or best practices to justify a config tweak.
* **Reviews:** Config files can sometimes contain subtle issues (like a stray comma in JSON, or a wrong section header). During review, double-check syntax or even copy the file and test it. Reviewers and agents should be thorough because a small config error can cause a feature not to work at all.

### Forbidden & Discouraged

* **No Secrets or Personal Info:** Reiterating globally: configuration files **must not** include secrets, API keys, passwords, or personal information. If an API config is absolutely needed for setup (which is uncommon), it should be left blank with instructions for the user to fill in later (and perhaps the script can prompt the user at runtime instead).
* **Do Not Hard-Code System-Specific Paths:** Avoid embedding paths that only exist on one particular system. For example, do not put `/Users/kristian/XYZ` in a config. Always use relative paths or user-specific placeholders. Mackup config, for instance, smartly just specifies `engine = icloud` without needing the actual path – Mackup figures it out. Similarly, if configuring something like a launch agent, use `~` for home directory rather than a literal path.
* **Avoid Binary or Large Config Blobs:** Do not add binary files or extremely large config files to the repository. Configs should be text-based and trackable in git. If a configuration export is only available in binary (like some apps export `.plist` binary files), find an alternative (perhaps convert to XML plist or a script to set those defaults via `defaults write`). We prefer human-readable configs under version control.
* **Don’t Override User Preferences Blindly:** A config file included here often serves as a default or template. The script currently copies `mackup.cfg` to the user’s home, potentially overwriting an existing file. This is done with `-f` force. This is acceptable for first-time run or if the user consents (implicitly by running setup). However, be cautious about future config files:

  * If the config is something a user might have customized, overwriting it could be impolite. For example, if we ever provided a `.gitconfig`, overwriting an existing one would erase their settings. In such cases, the agent should instead append or merge, or prompt the user.
  * Forbidden: blindly destroying user data. Always have a strategy (backup the old file, or prompt) if touching something that might exist.
* **One Configuration Source of Truth:** Avoid conflicts between multiple config files or methods that affect the same setting. For instance, do not have the script `defaults write` something that is also configured via a config file deployed. This could lead to confusion. Keep it organized: if a setting is managed in a config file, do it there; if via script, do it in script, but not both for the same thing.
* **Vendor-Specific Warnings:** If adding config for third-party tools, ensure it doesn’t violate any usage terms or best practices of that tool. E.g., some tools might discourage checking in certain config with credentials. Or a service might require not to expose certain IDs. Keep those in mind (this is rarely an issue for generic configs, but worth remembering).
* **No Dynamic Config in Repo:** Do not generate or modify the version-controlled config files at runtime. The ones in `configs/` should remain static templates. The script can copy or tweak them after copying out to the user’s directory if needed, but it should not rewrite the files inside the repository on the fly (that would make git state dirty and confuse version control). Any machine-specific adjustments should occur on the user’s copy, not in the repository file.
