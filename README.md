# Neovim Docker Images

![Docker Image CI](https://github.com/helton/neovim/actions/workflows/build.yml/badge.svg)

Containerized environments for popular Neovim distributions and quick starters. Ideal for constrained environments where a streamlined Neovim setup with essential plugins is required.

## Features

- **Multi-Platform Support**: Builds for both `linux/amd64` and `linux/arm64` architectures, ensuring compatibility with traditional x86 systems and ARM-based systems like Apple's M1/M2 chips.
- **Pre-installed Tools**: Comes with essential tools such as `bat`, `curl`, `fd-find`, `fzf`, `git`, `neovim`, `ripgrep`, `wget`, `zoxide`, and `zsh`.
- **Multiple Neovim Configurations**: Supports various Neovim configurations and quick starters like [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), [LazyVim](https://github.com/LazyVim/LazyVim), [NVChad](https://github.com/NvChad/NVChad), and [AstroVim](https://github.com/AstroNvim/AstroNvim).
- **Customizable**: Easily map your own configurations and keybindings via Docker volumes.

## Support Details

### Neovim

- 0.10.1: Latest release.

### Platforms

- **Linux Architectures**:
  - `linux/amd64`
  - `linux/arm64`

- **macOS**:
  - Runs seamlessly on macOS (including Apple Silicon) through Docker Desktop's virtualization layer.

### Supported Neovim Configurations

- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [LazyVim](https://github.com/LazyVim/LazyVim)
- [NVChad](https://github.com/NvChad/NVChad)
- [AstroVim](https://github.com/AstroNvim/AstroNvim)

### Base Images

- **Alpine 3.20**: Latest release.

### Pre-installed Tools

- `bat`: A `cat` clone with syntax highlighting and Git integration.
- `cmake`: C/C++ build tool.
- `curl`: Tool to transfer data from or to a server.
- `fd-find`: Simple, fast, and user-friendly alternative to `find`.
- `fzf`: A general-purpose command-line fuzzy finder.
- `git`: Version control system.
- `jq`: A lightweight and flexible command-line JSON processor.
- `ripgrep`: Line-oriented search tool that recursively searches directories.
- `wget`: Non-interactive network downloader.
- `zoxide`: A smarter `cd` command.
- `zsh`: Z shell, an extended Bourne shell with many improvements.

### Languages Tooling/Runtimes

- **Python**: 3.12.6
- **Golang**: 1.23.1
- **Rust**: 1.81.0
- **Node**: 20.17.0

## Installation

### Pulling the Docker Image

You can pull the pre-built Docker images from GitHub Container Registry.

```shell
docker pull ghcr.io/helton/neovim:kickstart.nvim-alpine-3.20
```

## Usage

### Running Neovim

To run Neovim using the Docker image:

```shell
docker run --rm -it ghcr.io/helton/neovim:kickstart.nvim-alpine-3.20
```

Or, to open Neovim in a specific directory:

```shell
docker run --rm -it -v $(pwd)/app:/app -w /app ghcr.io/helton/neovim:kickstart.nvim-alpine-3.20
```

Example commands:

```shell
docker run --rm -it -v ${PWD}/app:/app -w /app ghcr.io/helton/neovim:kickstart.nvim-alpine-3.20
docker run --rm -it -v ${PWD}/app:/app -w /app ghcr.io/helton/neovim:lazyvim-alpine-3.20
docker run --rm -it -v ${PWD}/app:/app -w /app ghcr.io/helton/neovim:nvchad-alpine-3.20
docker run --rm -it -v ${PWD}/app:/app -w /app ghcr.io/helton/neovim:astronvim-alpine-3.20
```

## Customization

You can customize your Neovim setup by mapping your own configurations and keybindings. This can be done by mounting your local Neovim configuration directory into the Docker container.

### Overriding Neovim Configuration

```shell
docker run --rm -it \
  -v ${PWD}/app:/app \
  -v ${HOME}/.config/nvim:/root/.config/nvim \
  -w /app \
  ghcr.io/helton/neovim:kickstart.nvim-alpine-3.20
```

### Notes on Custom Plugins

If you add new plugins to your Neovim configuration, ensure that they can be downloaded within the Docker image. Alternatively, use the default plugins provided by the image if you're operating in a constrained environment with limited network access.

## Development

### Build

To build the Docker images locally, ensure you have Docker Buildx installed and configured.

Run the build script:

```shell
./build.sh
```

This script utilizes Docker Buildx to build multi-platform images (linux/amd64 and linux/arm64).
The images will be tagged with the arch as suffix, like `neovim-kickstart.nvim-alpine-3.20-amd64`

### Run

To run built images locally, use commands like the following:

```shell
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:kickstart.nvim-alpine-3.20-amd64
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:kickstart.nvim-alpine-3.20-arm64
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:lazyvim-alpine-3.20-amd64
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:lazyvim-alpine-3.20-arm64
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:nvchad-alpine-3.20-amd64
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:nvchad-alpine-3.20-arm64
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:astronvim-alpine-3.20-amd64
docker run --rm -it -v ${PWD}/app:/app -w /app neovim:astronvim-alpine-3.20-arm64
```

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your enhancements.

## License

[MIT](LICENSE)
