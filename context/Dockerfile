ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG NVIM_PLUGIN_MANAGER
ARG NVIM_CONFIG_REPO_URL

ENV PATH="/usr/local/go/bin:/root/.cargo/bin:${PATH}"

RUN COMMON_PACKAGES="bat ca-certificates curl fzf git ripgrep wget zoxide zsh" && \
    APT_EXTRA_PACKAGES="build-essential fd-find" && \
    APK_EXTRA_PACKAGES="build-base fd" && \
    if [ -x "$(command -v apt-get)" ]; then \
        DEBIAN_FRONTEND=noninteractive apt-get update && \
        apt-get install -y --no-install-recommends $COMMON_PACKAGES $APT_EXTRA_PACKAGES python3 python3-pip && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
        apt-get install -y nodejs; \
    elif [ -x "$(command -v apk)" ]; then \
        apk update && \
        apk add --no-cache $COMMON_PACKAGES $APK_EXTRA_PACKAGES python3 py3-pip nodejs npm; \
    else \
        echo "Unsupported package manager. Only apt-get and apk are supported." && exit 1; \
    fi

RUN if [ -x "$(command -v fdfind)" ]; then \
        ln -s "$(command -v fdfind)" /usr/local/bin/fd; \
    elif [ -x "$(command -v fd)" ]; then \
        ln -s "$(command -v fd)" /usr/local/bin/fd; \
    fi

RUN curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep "browser_download_url.*nvim-linux64.tar.gz" \
    | cut -d '"' -f 4 \
    | wget -qi - \
    && tar xzf nvim-linux64.tar.gz \
    && mv nvim-linux64 /opt/neovim \
    && ln -s /opt/neovim/bin/nvim /usr/local/bin/nvim \
    && rm nvim-linux64.tar.gz

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && rustup update

RUN curl -LO https://golang.org/dl/go1.20.5.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz \
    && rm go1.20.5.linux-amd64.tar.gz

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
        nvim --headless +PackerSync +TSUpdate -c 'sleep 20' +qa ;; \
    "plug") \
        nvim --headless +PlugInstall +TSUpdate -c 'sleep 20' +qa ;; \
    "lazy") \
        nvim --headless +Lazy sync +TSUpdate -c 'sleep 20' +qa ;; \
esac

CMD ["nvim"]
