FROM ghcr.io/astral-sh/uv:trixie-slim

RUN useradd -m -s /usr/bin/zsh dev \
    && mkdir -p /etc/sudoers.d \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && apt-get update \
    && apt-get install -y sudo wget iputils-ping curl htop fzf rsync zsh zsh-autosuggestions gnupg gpg tmux luarocks locales ripgrep \
    && apt-get clean

RUN apt-get install -y ncurses-term starship atuin zoxide direnv

#COPY configs/.zshrc /home/dev/
#COPY configs/nvim/ /home/dev/.config/nvim
#COPY configs/tmux/ /home/dev/.config/tmux

#RUN chown -R dev:dev /home/dev

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen

USER dev

WORKDIR /home/dev

CMD ["sleep", "infinity"]
