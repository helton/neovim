ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

ARG NVIM_PLUGIN_MANAGER
ARG NVIM_CONFIG_REPO_URL

ENV PATH="/usr/local/go/bin:/root/.cargo/bin:/usr/local/bin:/usr/bin:${PATH}"
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH="/usr/local/cargo/bin:${PATH}"

ENV COMMON_PACKAGES="bat ca-certificates cmake curl fzf git ripgrep wget zoxide zsh"
ENV APT_EXTRA_PACKAGES="build-essential fd-find"
ENV APK_EXTRA_PACKAGES="autoconf automake build-base fd gettext-dev libtool libtermkey-dev libvterm-dev libuv-dev jansson-dev ninja pkgconf"

RUN if [ -x "$(command -v apt-get)" ]; then \
        apt-get update && \
        apt-get install -y --no-install-recommends $COMMON_PACKAGES $APT_EXTRA_PACKAGES && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*; \
    elif [ -x "$(command -v apk)" ]; then \
        apk update && \
        apk add --no-cache $COMMON_PACKAGES $APK_EXTRA_PACKAGES && \
        update-ca-certificates; \
    else \
        echo "Unsupported package manager. Only apt-get and apk are supported." && exit 1; \
    fi

# fd
RUN if [ -x "$(command -v fdfind)" ]; then \
        ln -s "$(command -v fdfind)" /usr/local/bin/fd; \
    elif [ -x "$(command -v fd)" ]; then \
        ln -s "$(command -v fd)" /usr/local/bin/fd; \
    fi

# zsh + ohmyzsh
RUN if [ -x "$(command -v zsh)" ]; then \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
    fi

# Rust
RUN if ! command -v rustup > /dev/null; then \
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path && \
        rustup update; \
    fi

# Golang
ENV GOLANG_VERSION=1.23.1
RUN curl -LO https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Python
ENV PYTHON_VERSION=3.12.6
RUN curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    cd / && \
    rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz

RUN python3 --version

# Node
ENV NODE_VERSION=20.9.0
RUN curl -LO https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz && \
    tar -xJf node-v${NODE_VERSION}-linux-x64.tar.xz && \
    mv node-v${NODE_VERSION}-linux-x64 /usr/local/node && \
    ln -s /usr/local/node/bin/node /usr/local/bin/node && \
    ln -s /usr/local/node/bin/npm /usr/local/bin/npm && \
    rm node-v${NODE_VERSION}-linux-x64.tar.xz

RUN node --version && \
    npm --version

# Neovim
RUN git clone --depth 1 https://github.com/neovim/neovim.git /tmp/neovim && \
    cd /tmp/neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make install && \
    cd / && \
    rm -rf /tmp/neovim

RUN nvim --version

RUN mkdir -p /root/.config && \
    git clone "${NVIM_CONFIG_REPO_URL}" /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

RUN case "${NVIM_PLUGIN_MANAGER}" in \
        "packer") \
            git clone --depth 1 https://github.com/wbthomason/packer.nvim /root/.local/share/nvim/site/pack/packer/start/packer.nvim ;; \
        "plug") \
            curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ;; \
        "lazy") \
            git clone https://github.com/folke/lazy.nvim.git /root/.config/nvim/lazy/lazy.nvim --branch=stable ;; \
        *) \
            echo "Unsupported NVIM_PLUGIN_MANAGER: ${NVIM_PLUGIN_MANAGER}. Supported options are: packer, plug, lazy." && exit 1 ;; \
    esac

RUN case "${NVIM_PLUGIN_MANAGER}" in \
        "packer") \
            nvim --headless +PackerSync +TSInstallSync all -c 'sleep 20' +qa ;; \
        "plug") \
            nvim --headless +PlugInstall +TSInstallSync all -c 'sleep 20' +qa ;; \
        "lazy") \
            nvim --headless +Lazy sync +TSInstallSync all -c 'sleep 20' +qa ;; \
    esac

CMD ["nvim"]
