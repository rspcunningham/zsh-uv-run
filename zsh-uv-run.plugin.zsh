# zsh-uv-run — smart tab completion for `uv run`
#
# Completes:
#   - [project.scripts] entry points from pyproject.toml
#   - .py files (recursively)
#   - executables from .venv/bin (filtered)
#   - directories (for navigating to nested files)
#
# Works from subdirectories — walks up to find pyproject.toml and .venv.
# Delegates to the original _uv completion for all other subcommands.
# Requires uv's generated completions to be loaded first (via the oh-my-zsh
# uv plugin or `eval "$(uv generate-shell-completion zsh)"`).

# Walk up from $PWD to find the nearest directory containing pyproject.toml
_uv_run_find_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/pyproject.toml" ]]; then
      echo "$dir"
      return 0
    fi
    dir="${dir:h}"
  done
  return 1
}

_uv_run_completion() {
  # Detect whether we're completing `uv run ...` or the `uvr` alias
  local is_alias=0 cmd_pos=3 min_current=3
  if [[ "${words[1]}" == "uvr" ]]; then
    is_alias=1
    cmd_pos=2
    min_current=2
  fi

  # For non-run subcommands (only applies to `uv`, not `uvr`), delegate
  if (( ! is_alias )); then
    if [[ "${words[2]}" != "run" ]] || (( CURRENT < 3 )); then
      _uv "$@"
      return
    fi
  elif (( CURRENT < min_current )); then
    return
  fi

  # Skip flags — let _uv handle those
  if [[ "${words[CURRENT]}" == -* ]]; then
    if (( is_alias )); then return; fi
    _uv "$@"
    return
  fi

  # Find which positional arg we're on (skip flags and their values)
  local pos=0 i
  for (( i=cmd_pos; i < CURRENT; i++ )); do
    [[ "${words[i]}" != -* ]] && (( pos++ ))
  done

  if (( pos == 0 )); then
    local project_root
    project_root="$(_uv_run_find_project_root)"

    local -a entry_points=()

    # Parse [project.scripts] from pyproject.toml
    if [[ -n "$project_root" && -f "$project_root/pyproject.toml" ]]; then
      entry_points=( ${(@f)"$(
        awk '/^\[project\.scripts\]/{found=1; next} /^\[/{found=0} found && /=/{sub(/\s*=.*/, ""); gsub(/\s/, ""); print}' "$project_root/pyproject.toml"
      )"} )
    fi

    # Collect .venv/bin executables, filtering out noise
    local -a venv_cmds=()
    local venv_dir="${project_root:-.}/.venv/bin"
    if [[ -d "$venv_dir" ]]; then
      venv_cmds=( ${(@f)"$(ls "$venv_dir" 2>/dev/null)"} )
      # Filter out python, pip, activate, and other venv internals
      venv_cmds=( ${venv_cmds:#python*} )
      venv_cmds=( ${venv_cmds:#pip*} )
      venv_cmds=( ${venv_cmds:#activate*} )
      venv_cmds=( ${venv_cmds:#Activate*} )
      venv_cmds=( ${venv_cmds:#deactivate} )
      venv_cmds=( ${venv_cmds:#.*} )
    fi

    _alternative \
      'scripts:pyproject.toml script:(${(j: :)entry_points})' \
      'pyfiles:python file:_files -g "**/*.py"' \
      'venv:venv executable:(${(j: :)venv_cmds})' \
      'dirs:directory:_files -/'
  else
    # After the command: complete files as arguments to the script
    _files
  fi
}

compdef _uv_run_completion uv
compdef _uv_run_completion uvr
