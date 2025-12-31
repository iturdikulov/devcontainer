# Based on:
# https://github.com/JetBrains/qodana-cli/blob/main/dockerfiles/base/python.Dockerfile
# original: https://github.com/JetBrains/qodana-cli/blob/f2e81df1b12a5c0d9d8d4c74f2e9a8fbe0c7e2dd/dockerfiles/base/python.Dockerfile#L1
# https://github.com/astral-sh/uv-docker-example/tree/main

ARG DEBIAN_BASE_TAG="trixie-slim"
ARG UV_TAG="uv:0.9.21-trixie-slim"
ARG NODE_TAG="25.2.1-trixie-slim"
ARG PYTHON_TAG="3.14.2-slim-trixie"


# ==========================================
# Fetch debian, uv, node and python layers
# ==========================================
FROM debian:${DEBIAN_BASE_TAG} AS base
FROM ghcr.io/astral-sh/${UV_TAG} AS uv_source
FROM node:${NODE_TAG} AS node_source

FROM python:${PYTHON_TAG} AS python_source
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
# Use the system Python interpreter
# https://docs.astral.sh/uv/reference/environment/#uv_python_downloads
ENV UV_PYTHON_DOWNLOADS="manual"
# Avoid prompts
ENV DEBIAN_FRONTEND noninteractive

# Install uv
# ==========================================
COPY --from=uv_source /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/


# ==========================================
# Development stage
# ==========================================
FROM python_source AS development

ARG UID=1000
ARG GID=1000
ARG USERNAME=dev

# Install Node.js, npm, yarn (Copying the whole /usr/local structure works best for Node)
# ==========================================
ENV ESLINT_VERSION="9.31.0"
ENV PNPM_VERSION="10.13.1"

ENV PATH="/opt/yarn/bin:$PATH"
ENV SKIP_YARN_COREPACK_CHECK=0
COPY --from=node_source /usr/local/bin/node /usr/local/bin/
COPY --from=node_source /usr/local/include/node /usr/local/include/node
COPY --from=node_source /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node_source /opt/yarn-* /opt/yarn/

RUN apt-get update && apt-get install -y xz-utils libatomic1 --no-install-recommends && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -s /usr/local/lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack && \
    node --version && \
    npm --version && \
    yarn --version && \
    npm install -g eslint@$ESLINT_VERSION pnpm@$PNPM_VERSION

# Install base dependencies and configure the environment
# ==========================================
# https://docs.docker.com/reference/dockerfile/#example-cache-apt-packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get --no-install-recommends install -y \
    bat \
    coreutils \
    curl \
    fd-find \
    fzf \
    git \
    gnupg \
    gpg \
    htop \
    iputils-ping \
    jq \
    ncdu \
    ripgrep \
    rsync \
    sudo \
    tmux \
    unzip \
    zip \
    zoxide \
    zsh \
    zsh-autosuggestions \
    nano \
    micro \
    vim \
    direnv

# Setup a non-root user
RUN groupadd --system --gid 1000 dev \
 && useradd --shell /usr/bin/zsh --system --gid ${UID} --uid ${GID} --create-home ${USERNAME}

RUN mkdir -p /etc/sudoers.d \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

# Switch to user "dev" from now
USER ${USERNAME}
WORKDIR /home/${USERNAME}
CMD ["sleep", "infinity"]
