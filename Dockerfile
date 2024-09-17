ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG NVIM_PLUGIN_MANAGER
ARG NVIM_CONFIG_REPO_URL

RUN if [ -x "$(command -v apt-get)" ]; then \
        DEBIAN_FRONTEND=noninteractive \
        apt-get update && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            wget \
            git \
            zsh \
            neovim \
            bat \
            ripgrep \
            fzf \
            fd-find \
            zoxide \
            build-essential \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; \
    elif [ -x "$(command -v apk)" ]; then \
        apk update && apk add --no-cache \
            ca-certificates \
            curl \
            wget \
            git \
            zsh \
            neovim \
            bat \
            ripgrep \
            fzf \
            fd \
            zoxide \
            build-base \
        && update-ca-certificates; \
    else \
        echo "Unsupported package manager. Only apt-get and apk are supported." && exit 1; \
    fi

RUN if [ -x "$(command -v fdfind)" ]; then \
        ln -s "$(command -v fdfind)" /usr/local/bin/fd; \
    elif [ -x "$(command -v fd)" ]; then \
        ln -s "$(command -v fd)" /usr/local/bin/fd; \
    fi

RUN if [ -x "$(command -v zsh)" ]; then \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
    fi

RUN mkdir -p /root/.config
RUN git clone "${NVIM_CONFIG_REPO_URL}" /root/.config/nvim
RUN rm -rf /root/.config/nvim/.git

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
