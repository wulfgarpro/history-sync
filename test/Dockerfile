FROM ubuntu:22.04

# Install system packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    zsh \
    gpg \
    gpg-agent \
    ripgrep \
  && rm -rf /var/lib/apt/lists/*

# Install oh-my-zsh and history-sync plugin
RUN bash -c 'set -o pipefail && curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -e' \
  && mkdir -p /root/.oh-my-zsh/plugins/history-sync
COPY history-sync.plugin.zsh /root/.oh-my-zsh/plugins/history-sync/
# Install a basic `zshrc`
COPY test/zshrc /root/.zshrc
# Install the test script
COPY test/test.zsh /root
RUN chmod +x /root/test.zsh

ARG ACCESS_KEY
ENV ACCESS_KEY=${ACCESS_KEY}
ENTRYPOINT ["/usr/bin/zsh"]
CMD ["-i", "-c", "source /root/test.zsh ${ACCESS_KEY}"]
