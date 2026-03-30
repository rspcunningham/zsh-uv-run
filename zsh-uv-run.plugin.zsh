# zsh-uv-run — smart tab completion for `uv run`
#
# Completes:
#   - [project.scripts] entry points from pyproject.toml
#   - .py files in the current directory
#   - executables from .venv/bin
#   - directories (for navigating to nested files)
#
# Delegates to the original _uv completion for all other subcommands.
# Requires uv's generated completions to be loaded first (via the oh-my-zsh
# uv plugin or `eval "$(uv generate-shell-completion zsh)"`).

_uv_run_completion() {
  # For non-run subcommands, delegate to the original generated completion
  if [[ "${words[2]}" != "run" ]] || (( CURRENT < 3 )); then
    _uv "$@"
    return
  fi

  # Skip flags — let _uv handle those
  if [[ "${words[CURRENT]}" == -* ]]; then
    _uv "$@"
    return
  fi

  # Find which positional arg we're on (skip flags and their values)
  local pos=0 i
  for (( i=3; i < CURRENT; i++ )); do
    [[ "${words[i]}" != -* ]] && (( pos++ ))
  done

  if (( pos == 0 )); then
    local -a entry_points=()

    # Parse [project.scripts] from pyproject.toml
    if [[ -f pyproject.toml ]]; then
      entry_points=( ${(@f)"$(
        awk '/^\[project\.scripts\]/{found=1; next} /^\[/{found=0} found && /=/{sub(/\s*=.*/, ""); gsub(/\s/, ""); print}' pyproject.toml
      )"} )
    fi

    # Collect .venv/bin executables (installed packages + entry points)
    local -a venv_cmds=()
    if [[ -d .venv/bin ]]; then
      venv_cmds=( ${(@f)"$(ls .venv/bin/ 2>/dev/null)"} )
    fi

    _alternative \
      'scripts:pyproject.toml script:(${(j: :)entry_points})' \
      'pyfiles:python file:_files -g "*.py"' \
      'venv:venv executable:(${(j: :)venv_cmds})' \
      'dirs:directory:_files -/'
  else
    # After the command: complete files as arguments to the script
    _files
  fi
}

compdef _uv_run_completion uv
