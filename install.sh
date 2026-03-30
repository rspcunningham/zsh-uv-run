#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/rspcunningham/zsh-uv-run.git"
PLUGIN_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-uv-run"
ZSHRC="${HOME}/.zshrc"

# Clone plugin
if [[ -d "$PLUGIN_DIR" ]]; then
  echo "Already installed at $PLUGIN_DIR"
else
  echo "Cloning into $PLUGIN_DIR..."
  git clone --depth 1 "$REPO" "$PLUGIN_DIR"
fi

# Add to oh-my-zsh plugins list (after uv if present, otherwise at end)
if grep -qE 'plugins=\(.*zsh-uv-run' "$ZSHRC"; then
  echo "zsh-uv-run already in plugins list"
elif grep -qE 'plugins=\(' "$ZSHRC"; then
  if grep -qE 'plugins=\(.*\buv\b' "$ZSHRC"; then
    # Insert after 'uv'
    sed -i.bak 's/\(plugins=(.*\buv\b\)/\1 zsh-uv-run/' "$ZSHRC"
  else
    # Append before closing paren
    sed -i.bak 's/\(plugins=([^)]*\)/\1 zsh-uv-run/' "$ZSHRC"
  fi
  rm -f "${ZSHRC}.bak"
  echo "Added zsh-uv-run to plugins in $ZSHRC"
else
  echo "Warning: no plugins=(...) found in $ZSHRC — add zsh-uv-run manually"
fi

echo "Done! Run: source ~/.zshrc"
