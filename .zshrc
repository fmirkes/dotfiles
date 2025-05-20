## Env vars
export EDITOR='vim'

export HOMEBREW_NO_EMOJI=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

## Aliases
alias ls='ls --color'
alias ll='ls -l'

alias eza='eza --color=never --long --git --git-repos'

alias grep='grep --color'

alias gti='git'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

alias ssh-unsafe='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

alias mosh='LC_ALL=en_US.UTF-8 mosh'

alias readlink='greadlink'
alias shred='gshred'

# https://stackoverflow.com/a/18247437
alias tmux='EDITOR= tmux -2'

## Prompt
setopt PROMPT_SUBST

autoload -U colors && colors

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

export PROMPT='[%(?.0.%{$fg_bold[red]%}!%{$reset_color%})]%(!.[%{$fg_bold[red]%}root%{$reset_color%}].)[%(!.%{$fg_bold[red]%}.%{$fg[cyan]%})%~%{$reset_color%}]$(__git_prompt)%(!.%{$fg_bold[red]%}#.$)%{$reset_color%} '

## Completion
setopt COMPLETE_ALIASES

zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion::complete:*' gain-privileges 1

# add external completions
fpath=('/opt/local/share/zsh/site-functions' $fpath) 
fpath=('/opt/local/share/zsh/vendor-completions' $fpath) 

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

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

## External

# zsh-autosuggestions
source '/opt/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh'

# fzf
export FZF_DEFAULT_OPTS='--no-color --style=minimal'
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'

source '/opt/local/share/fzf/shell/completion.zsh'
source '/opt/local/share/fzf/shell/key-bindings.zsh'

## display info on login
if [[ -o login ]]; then
  if [[ "${TERM_PROGRAM}" != 'vscode' ]] && [[ "${TERM_PROGRAM}" != 'zed' ]]; then
    task next 2>/dev/null || true 
  fi
fi

