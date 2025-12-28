# based on
# https://github.com/astral-sh/uv-docker-example/blob/main/multistage.Dockerfile
FROM debian:trixie-slim AS base

WORKDIR /app

# UV
# ----
ENV UV_VERSION=0.9.18
ENV PYTHON_VERSION=3.14
ENV UV_INSTALL_DIR=/usr/local/bin

# The installer requires curl (and certificates) to download the release archive
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates

# Download the installer
ADD https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-installer.sh /uv-installer.sh

# Verify installer
# to get sha256sum run `UV_VERSION=<VERSION> curl -fsSL https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-installer.sh | sha257sum`
RUN echo "e27424708d1ac59cfc94e3f540a111f2edbb37bc8164febce8ee7fa5d5505c71  /uv-installer.sh" | sha256sum -c -

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Omit development dependencies
ENV UV_NO_DEV=1

# Configure the Python directory so it is consistent
ENV UV_PYTHON_INSTALL_DIR=/python

# Only use the managed Python version
ENV UV_PYTHON_PREFERENCE=only-managed

# Install Python before the project for caching
RUN uv python install ${PYTHON_VERSION}

# NODE
# ----
# based on https://github.com/nodejs/docker-node/blob/main/25/trixie-slim/Dockerfile
ENV NODE_VERSION=25.2.1
ENV NODE_BASE_URL=https://mirror.yandex.ru/mirrors/nodejs.org/dist

RUN ARCH= OPENSSL_ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
      amd64) ARCH='x64' OPENSSL_ARCH='linux-x86_64';; \
      ppc64el) ARCH='ppc64le' OPENSSL_ARCH='linux-ppc64le';; \
      s390x) ARCH='s390x' OPENSSL_ARCH='linux*-s390x';; \
      arm64) ARCH='arm64' OPENSSL_ARCH='linux-aarch64';; \
      armhf) ARCH='armv7l' OPENSSL_ARCH='linux-armv4';; \
      i386) ARCH='x86' OPENSSL_ARCH='linux-elf';; \
      *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && set -ex \
    # libatomic1 for arm
    && apt-get update && apt-get install -y ca-certificates curl wget gnupg dirmngr xz-utils libatomic1 --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
    && export GNUPGHOME="$(mktemp -d)" \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    && for key in \
      5BE8A3F6C8A5C01D106C0AD820B1A390B168D356 \
      DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
      CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      A363A499291CBBC940DD62E41F10027AF002F8B0 \
    ; do \
      { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } || \
      { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ; \
    done \
    && curl -fsSLO --compressed "${NODE_BASE_URL}/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && curl -fsSLO --compressed "${NODE_BASE_URL}/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    # Remove unused OpenSSL headers to save ~34MB. See this NodeJS issue: https://github.com/nodejs/node/issues/46451
    && find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} \; \
    && apt-mark auto '.*' > /dev/null \
    && find /usr/local -type f -executable -exec ldd '{}' ';' \
      | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
      | sort -u \
      | xargs -r dpkg-query --search \
      | cut -d: -f1 \
      | sort -u \
      | xargs -r apt-mark manual \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    # smoke tests
    && node --version \
    && npm --version \
    && rm -rf /tmp/*


# There is specific pull issue with additional_contexts, devcontainers and own dockerfile
# so I placed devcontainer setup here
FROM base AS development

ARG UID=1000
ARG GID=1000
ARG USERNAME=dev

# Basic dependencies
RUN apt-get update && \
    apt-get install -y sudo wget iputils-ping htop git fzf rsync gnupg gpg tmux ripgrep zsh zsh-autosuggestions \
    && apt-get clean

# Setup a non-root user
RUN groupadd --system --gid 1000 dev \
 && useradd --shell /usr/bin/zsh --system --gid ${UID} --uid ${GID} --create-home ${USERNAME}

RUN mkdir -p /etc/sudoers.d \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

# Switch to user "dev" from now
USER ${USERNAME}
WORKDIR /home/${USERNAME}
CMD ["sleep", "infinity"]
