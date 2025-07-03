# Setup macOS

Install apps and configure Mac.

## Installation

Run the command below in your terminal and the installation will start automatically.
Just follow the prompts and you’ll be fine. 👌

``` bash
git clone https://github.com/EpicKris/setup-macos.git ~/.setup-macos && ~/.setup-macos/setup
```

## What Will You Get?

1. A ridiculously fast web development setup…

- [nginx][nginx]
- [Swift][swift]

2. [Visual Studio Code][visual-studio-code] as a text editor.

3. A set of relevant apps…
	- [Firefox][firefox]
	- [Google Chrome][google-chrome]
	- [IINA][iina]

See [`apps/app-store`](apps/app-store) and [`apps/cask`](apps/cask) for the full list of apps that will be installed.
Adjust it to your personal taste.

[firefox]: https://firefox.com
[google-chrome]: https://chrome.google.com
[iina]: https://iina.io
[nginx]: https://nginx.org
[swift]: https://swift.sorting
[visual-studio-cdoe]: https://code.visualstudio.com

## Development Container

Use [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) or GitHub Codespaces to develop.
Open this project in VS Code and the extension will prompt you to rebuild using the included configuration.
