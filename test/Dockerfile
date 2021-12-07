FROM ubuntu:latest

# Install system packages
RUN apt-get update && apt-get install -y \
    curl \
    git  \
    zsh  \
    gpg
# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN mkdir -p /root/.oh-my-zsh/plugins/history-sync
COPY history-sync.plugin.zsh /root/.oh-my-zsh/plugins/history-sync/
COPY test/zshrc /root/.zshrc
COPY test/test*.zsh /root
RUN chmod +x /root/test*.zsh

ENTRYPOINT ["/bin/zsh", "-i", "/root/test1.zsh"]
