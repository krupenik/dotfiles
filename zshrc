set_ruby() {
  local v=$1
  local default=3.3

  if [[ $v == "" ]]; then
    if [[ -f Gemfile ]]; then
      v=$(grep -E '^ruby.*?\d\.\d' Gemfile | grep -Eo '\d\.\d')
    elif [[ -f .ruby-version ]]; then
      v=$(head -c 3 .ruby-version)
    else
      v=$default
    fi
  fi

  PATH=${(S)PATH/\/ruby\/gems\/*\/bin/\/ruby\/gems\/$v.0\/bin}

  if [[ $v == "$default" ]]; then
    PATH=${(S)PATH/\/opt\/ruby*\/bin/\/opt\/ruby\/bin}
  else
    PATH=${(S)PATH/\/opt\/ruby*\/bin/\/opt\/ruby@$v\/bin}
  fi

  ruby -v
}

git_rebase_all() {
  local main=${1:-master}
  local current=$(git branch --show-current)

  git stash
  git checkout $main
  git pull

  for i in $(git branch --merged $main | grep -v " $main\$"); do
    git branch -d $i
    git push origin --delete $i
  done

  for i in $(git branch | grep -v " $main\$"); do
    git checkout $i
    git rebase $main
  done

  git push --all -f

  git checkout $current
  git stash pop
}

setopt no_beep
setopt prompt_subst
setopt append_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

alias ssh='ssh -AC'
alias ls='ls -G'
alias be='bundle exec'
alias gem_release='rm -f *.gem; gem build *.gemspec; gem push *.gem'
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'
alias vi=nvim
alias vim=nvim
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'

autoload -Uz compinit && compinit
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' at %b'

precmd_functions+=( vcs_info )

PS1='%(!.%F{red}%m%f.%F{green}%n%f@%m):%~${vcs_info_msg_0_}
%# '

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
EDITOR=nvim
VISUAL=nvim

prompt_command() {
  printf "\e]0;${USERNAME}@${HOST/%.*}:${PWD/#$HOME/~}\007"
}

precmd_functions+=( prompt_command )

ssh-add &> /dev/null

[[ -f Gemfile || -f .ruby-version ]] && set_ruby
