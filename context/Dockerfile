ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG NVIM_PLUGIN_MANAGER
ARG NVIM_CONFIG_REPO_URL

ENV PATH="/usr/local/go/bin:/root/.cargo/bin:/usr/local/bin:${PATH}"

ENV COMMON_PACKAGES="bat ca-certificates curl fzf git ripgrep wget zoxide zsh"
ENV APT_EXTRA_PACKAGES="build-essential fd-find"
ENV APK_EXTRA_PACKAGES="autoconf automake build-base cmake gettext-dev libtool libtermkey-dev libvterm-dev libuv-dev jansson-dev ninja pkgconf python3 py3-pip nodejs npm"

RUN if [ -x "$(command -v apt-get)" ]; then \
        apt-get update && \
        apt-get install -y --no-install-recommends $COMMON_PACKAGES $APT_EXTRA_PACKAGES python3 python3-pip && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
        apt-get install -y nodejs; \
    elif [ -x "$(command -v apk)" ]; then \
        apk update && \
        apk add --no-cache $COMMON_PACKAGES $APK_EXTRA_PACKAGES && \
        update-ca-certificates; \
    else \
        echo "Unsupported package manager. Only apt-get and apk are supported." && exit 1; \
    fi

RUN if [ -x "$(command -v fdfind)" ]; then \
        ln -s "$(command -v fdfind)" /usr/local/bin/fd; \
    elif [ -x "$(command -v fd)" ]; then \
        ln -s "$(command -v fd)" /usr/local/bin/fd; \
    fi

RUN if [ -x "$(command -v apt-get)" ]; then \
        git clone --depth 1 https://github.com/neovim/neovim.git /tmp/neovim && \
        cd /tmp/neovim && \
        make CMAKE_BUILD_TYPE=Release && \
        make install && \
        cd / && \
        rm -rf /tmp/neovim && \
        nvim --version; \
    elif [ -x "$(command -v apk)" ]; then \
        git clone --depth 1 https://github.com/neovim/neovim.git /tmp/neovim && \
        cd /tmp/neovim && \
        make CMAKE_BUILD_TYPE=Release && \
        make install && \
        cd / && \
        rm -rf /tmp/neovim && \
        nvim --version; \
    fi

RUN if [ -x "$(command -v rustup)" ]; then \
        rustup update; \
    fi

RUN curl -LO https://golang.org/dl/go1.20.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz && \
    rm go1.20.5.linux-amd64.tar.gz

RUN if [ -x "$(command -v zsh)" ]; then \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
    fi

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
