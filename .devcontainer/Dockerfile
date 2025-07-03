FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    git \
    shellcheck \
    shfmt \
    ca-certificates \
  && curl -fsSL https://github.com/rhysd/actionlint/releases/latest/download/actionlint_linux_amd64.tar.gz \
    | tar xz -C /usr/local/bin actionlint \
  && chmod +x /usr/local/bin/actionlint \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
