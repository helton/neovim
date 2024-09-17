#!/bin/bash

set -e

base_images=(
  "ubuntu:24.04"
  "alpine:3.20"
)

neovim_configurations=(
  "kickstart.nvim https://github.com/nvim-lua/kickstart.nvim lazy"
  "lazyvim        https://github.com/LazyVim/starter         lazy"
  "nvchad         https://github.com/NvChad/starter          packer"
  "astronvim      https://github.com/AstroNvim/template      lazy"
)

architectures=(
  "linux/amd64"
  "linux/arm64"
)

sanitize_image_name() {
  local image="$1"
  sanitized="${image//:/-}"
  sanitized="${sanitized//\//-}"
  echo "$sanitized"
}

build_image() {
  local base_image="$1"
  local repo_name="$2"
  local repo_url="$3"
  local plugin_manager="$4"
  local arch="$5"

  local sanitized_base=$(sanitize_image_name "$base_image")

  local arch_suffix
  arch_suffix=$(echo "$arch" | awk -F'/' '{print $2}')

  local tag="neovim:${repo_name}-${sanitized_base}-${arch_suffix}"

  echo ">>> Building Docker image: ${tag} for architecture: ${arch}"

  docker buildx build --platform "$arch" \
    --build-arg BASE_IMAGE="${base_image}" \
    --build-arg NVIM_CONFIG_REPO_URL="${repo_url}" \
    --build-arg NVIM_PLUGIN_MANAGER="${plugin_manager}" \
    -t "${tag}" \
    --load \
    context

  echo ">>> Successfully built: ${tag}"
  echo "----------------------------------------"
}

for base_image in "${base_images[@]}"; do
  for config in "${neovim_configurations[@]}"; do
    IFS=' ' read -r repo_name repo_url plugin_manager <<< "$config"

    if [[ "$plugin_manager" != "packer" && "$plugin_manager" != "plug" && "$plugin_manager" != "lazy" ]]; then
      echo "Error: Unsupported NVIM_PLUGIN_MANAGER '${plugin_manager}' for repository '${repo_name}'. Supported options are: packer, plug, lazy."
      exit 1
    fi

    for arch in "${architectures[@]}"; do
      build_image "$base_image" "$repo_name" "$repo_url" "$plugin_manager" "$arch"
    done
  done
done

echo "All Docker images have been built successfully."
