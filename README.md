# zsh-uv-run

Smart tab completion for [`uv run`](https://docs.astral.sh/uv/reference/cli/#uv-run). The built-in `uv` shell completions don't complete runnable targets — this plugin fills that gap.

## What it completes

When you type `uv run <TAB>` (or `uvr <TAB>`):

- **`[project.scripts]`** entry points from `pyproject.toml` (e.g. `bench`, `serve`)
- **`.py` files** recursively (e.g. `tests/test_foo.py`)
- **`.venv/bin` executables** — installed packages and tools (e.g. `pytest`, `ruff`), with noise like `python`, `pip`, and `activate` filtered out
- **Directories** — navigate into subdirs

Works from subdirectories — walks up to find `pyproject.toml` and `.venv` in the project root.

After the command (`uv run main.py <TAB>`), it falls back to general file completion for script arguments.

All other `uv` subcommands (`uv add`, `uv sync`, etc.) are delegated to the original `_uv` completion unchanged.

## Requirements

`uv`'s generated completions must be loaded before this plugin. This is satisfied by either:
- The [oh-my-zsh `uv` plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/uv) (recommended)
- `eval "$(uv generate-shell-completion zsh)"` in your `.zshrc`

## Install

### [Oh My Zsh](https://ohmyz.sh) (one-liner)

```zsh
curl -fsSL https://raw.githubusercontent.com/rspcunningham/zsh-uv-run/main/install.sh | sh
```

This clones the plugin and adds it to your `plugins=(...)` list automatically.

<details>
<summary>Manual oh-my-zsh install</summary>

```zsh
git clone https://github.com/rspcunningham/zsh-uv-run ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-uv-run
```

Add it to your plugins list in `~/.zshrc` **after** `uv`:

```zsh
plugins=(... uv zsh-uv-run ...)
```

</details>

### [zinit](https://github.com/zdharma-continuum/zinit)

```zsh
zinit light rspcunningham/zsh-uv-run
```

### [antidote](https://getantidote.github.io)

Add to your `.zsh_plugins.txt`:

```
rspcunningham/zsh-uv-run
```

### [sheldon](https://sheldon.cli.rs)

```toml
[plugins.zsh-uv-run]
github = "rspcunningham/zsh-uv-run"
```

### Manual

```zsh
git clone https://github.com/rspcunningham/zsh-uv-run ~/.zsh-uv-run
echo 'source ~/.zsh-uv-run/zsh-uv-run.plugin.zsh' >> ~/.zshrc
```

## License

MIT
