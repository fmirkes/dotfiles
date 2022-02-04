## Env vars
export EDITOR=vim

# Minikube
#  deactivate emoji bs
export MINIKUBE_IN_STYLE=false 

## Aliases
alias ls='ls --color'
alias ll='ls -l'
alias llh='ll -h'
alias lla='ll -a'
alias llha='llh -a'
alias llah='lla -h'

alias grep='grep --color'

alias gti='git'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

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

autoload -Uz compinit
compinit

compdef dotfiles=git
compdef gti=git

## History
HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE

setopt hist_ignore_dups
setopt hist_ignore_space

setopt inc_append_history 
setopt share_history

## External

[[ -d ~/.zsh/zsh-history-substring-search ]] || git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.zsh/zsh-history-substring-search
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=cyan,fg=white,bold"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

[[ -d ~/.zsh/zsh-autosuggestions ]] || git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -d ~/.zsh/zsh-completions ]] || git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
fpath=(~/.zsh/zsh-completions/src $fpath)

