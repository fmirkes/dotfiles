## OS detection
[[ "$(uname)" == 'Darwin' ]] && _IS_MACOS='true'
[[ -f '/etc/arch-release' ]] &&  _IS_ARCHLINUX='true'

## Fix keybindings
if [[ -n '_IS_ARCHLINUX' ]]; then
  bindkey -e

  bindkey "^[[H"  beginning-of-line
  bindkey "^[[F"  end-of-line
  bindkey "^[[3~" delete-char
fi

## Env Vars
export EDITOR='vim'
export VISUAL='vim'

# homebrew
if [[ -v '_IS_MACOS' ]]; then
  export HOMEBREW_NO_EMOJI=1
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
fi

## Aliases
alias ls='ls --color'
alias ll='ls -l'

alias eza='eza --color=never --long --git --git-repos'

alias grep='grep --color'

alias gti='git'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

alias ssh-unsafe='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

alias mosh='LC_ALL=en_US.UTF-8 mosh'

# https://stackoverflow.com/a/18247437
alias tmux='EDITOR= tmux -2'

alias vi='vim'

# macos specific aliases
if [[ -v '_IS_MACOS' ]]; then
  alias readlink='greadlink'
  alias shred='gshred'
fi

## Prompt
setopt PROMPT_SUBST

autoload -U colors && colors

function __hostname_prompt() {
  local _prompt

  if [[ -n "${SSH_CLIENT}" || -n "${SSH_CONNECTION}" ]]; then
    _prompt="[%{$fg_bold[red]%}%M%{$reset_color%}]"
  fi

  echo -n "${_prompt}"
}

function __git_prompt() {
  local _prompt
  
  local -r _branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ -n "${_branch}" ]]; then
    _prompt+="["
    
    if [[ "${_branch}" == "HEAD" ]]; then
      local -r _commit_hash="$(git rev-parse --short HEAD 2>/dev/null)"
      local -r _commit_tag="$(git tag --points-at "${_commit_hash}" 2>/dev/null | head -n 1 2>/dev/null)"
      
      if [[ -n "${_commit_tag}" ]]; then
        _prompt+="${_commit_tag}"
      elif [[ -n "${_commit_hash}" ]]; then
        _prompt+="${_commit_hash}"
      else
        _prompt+="${_branch}"
      fi
    else
      _prompt+="${_branch}"
    fi

    local _rebase=''
    if [[ -d "$(readlink -eq $(git rev-parse --git-path rebase-merge))"  ]] || [[ -d "$(readlink -eq $(git rev-parse --git-path rebase-apply))" ]]; then
      _rebase='true'
    fi

    local -r _status="$(git status -sb --porcelain 2>/dev/null)"
    local -r _ahead="$(grep ahead <<<("${_status}"))"
    local -ri _dirty=$(wc -l <<<("${_status}"))
  
    if [[ -n "${_rebase}" ]] || [[ -n "${_ahead}" ]] || [[ "${_dirty}" -gt 1 ]]; then
      _prompt+=" "
    fi
  
    [[ -n "${_rebase}" ]] && _prompt+="%{$fg_bold[yellow]%}%{r%G%}%{$reset_color%}"
    [[ -n "${_ahead}" ]] && _prompt+="%{$fg_bold[yellow]%}%{↑%G%}%{$reset_color%}"
    [[ "${_dirty}" -gt 1 ]] && _prompt+="%{$fg_bold[yellow]%}%{✗%G%}%{$reset_color%}"

    _prompt+="]"
  fi

  echo -n "${_prompt}"
}

export PROMPT='[%(?.0.%{$fg_bold[red]%}!%{$reset_color%})]%(!.[%{$fg_bold[red]%}root%{$reset_color%}].)$(__hostname_prompt)[%(!.%{$fg_bold[red]%}.%{$fg[cyan]%})%~%{$reset_color%}]$(__git_prompt)%(!.%{$fg_bold[red]%}#.$)%{$reset_color%} '

## Completion
setopt COMPLETE_ALIASES

zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion::complete:*' gain-privileges 1

# homebrew
if [[ -v '_IS_MACOS' ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# rebuild completion db (~/.zcompdump)
autoload -Uz compinit
compinit

# activate completion for aliases
compdef dotfiles=git
compdef gti=git
compdef ssh-unsafe=ssh

## History
HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE

setopt hist_ignore_dups
setopt hist_ignore_space

setopt inc_append_history 
setopt share_history

## Other
setopt correct

## External

# zsh-autosuggestions
[[ -v '_IS_MACOS' ]] && source '/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
[[ -v '_IS_ARCHLINUX' ]] && source '/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'

# zsh-autopair
[[ -v '_IS_MACOS' ]] && source '/opt/homebrew/share/zsh-autopair/autopair.zsh'
[[ -v '_IS_ARCHLINUX' ]] && source '/usr/share/zsh/plugins/zsh-autopair/autopair.zsh'

# fzf
export FZF_DEFAULT_OPTS='--no-color --style=minimal'
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'

[[ -v '_IS_MACOS' ]] && source '/opt/homebrew/opt/fzf/shell/completion.zsh'
[[ -v '_IS_MACOS' ]] && source '/opt/homebrew/opt/fzf/shell/key-bindings.zsh'

[[ -v '_IS_ARCHLINUX' ]] && source '/usr/share/fzf/completion.zsh'
[[ -v '_IS_ARCHLINUX' ]] && source '/usr/share/fzf/key-bindings.zsh'

## display info on login
if [[ -o 'login' ]] || [[ -v 'DESKTOP_SESSION' ]]; then
  if [[ "${TERM_PROGRAM}" != 'vscode' ]] && [[ "${TERM_PROGRAM}" != 'zed' ]]; then
    task next 2>/dev/null || true 
  fi
fi


