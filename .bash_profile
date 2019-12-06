#export subl as default editor and add symlinks
export TERM=xterm-256color
export PATH=/bin:/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:$HOME/Library/Haskell/bin:/Users/kylesnowschwartz/.local/bin:$PATH
export EDITOR='subl -w'
# export SSL_CERT_FILE=/usr/local/etc/openssl/cert.pem

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Useful aliases

alias reload="source ~/.bash_profile"
alias e=subl
alias be="bundle exec"

alias killrails="kill -9 $(lsof -i tcp:3000 -t)"

alias mkdir='mkdir -v'
alias cp='cp -v'
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete && find . -name 'Thumbs.db' -type f -ls -delete"
alias c="clear"
alias pythonserver="python -m SimpleHTTPServer 9393"

explain () {
  url="http://explainshell.com/explain?cmd=${@}"
  open "${url}"
}

elmmake () {
  elm-make src/Main.elm --yes --warn --output=elm.js
}

#Powershop aliases
alias wipdb="RAILS_ENV=development DB_NAME=powershop_production DB_USER=wip MYSQL_SERVER=127.0.0.1 MYSQL_PORT=3324"
# usage: ssh <wip-ssh-name> -N -v -L 3324:maria:3306
# wipdb <country> rails c

alias review='open "https://git.fluxfederation.com/powerapps/powershop/compare/master...$(git symbolic-ref --short HEAD)"'

alias jira='open "https://jira.powershophq.com/browse/$(git symbolic-ref --short HEAD)"'
alias ci='open "https://ci.fluxfederation.com/job/coreapp-branch-only/job/$(git symbolic-ref --short HEAD)"'

alias audeploy='open "https://deployer.test.powershop.com.au"'
alias nzdeploy='open "https://deployer.test.powershop.co.nz"'
alias ukdeploy='open "https://deployer.test.powershop.co.uk"'
alias merxdeploy='open "https://wippy.merx.fluxfederation.com/"'

alias wipssh='RLWRAP_HOME="$HOME/.rlwrap" rlwrap -a ssh'

alias nz="COUNTRY=nz be"
alias au="COUNTRY=au be"
alias uk="COUNTRY=uk be"

alias psau="COUNTRY=au RETAILER=psau RETAIL_BRAND=powershop be"
alias psuk="COUNTRY=uk RETAILER=psuk RETAIL_BRAND=powershop be"
alias psnz="COUNTRY=nz RETAILER=psnz RETAIL_BRAND=powershop be"

alias merx="RETAILER=merx RETAIL_BRAND=meridian COUNTRY=nz be"
alias powershop="RETAILER=psnz RETAIL_BRAND=powershop"
alias dcpower="RETAILER=psau RETAIL_BRAND=dcpowerco COUNTRY=au be"
alias kogan="RETAILER=psau RETAIL_BRAND=dcpowerco COUNTRY=au be"

alias nzrspec="COUNTRY=nz be spring rspec"
alias aurspec="COUNTRY=au be spring rspec"
alias ukrspec="COUNTRY=uk be spring rspec"

alias ukprodlon="ssh uk-prod-app-lon1-d10"
alias ukprodfra="ssh uk-prod-app-fra2-d10"
alias nzprodakl="ssh nz-prod-app-akl1-d10"
alias nzprodwlg="ssh nz-prod-app-wlg1-d10"
alias auprodakl="ssh au-prod-app-akl1-d10"
alias auprodwlg="ssh au-prod-app-wlg1-d10"

active () {
    case "$1" in
        nz) host="secure.powershop.co.nz" ;;
        au) host="secure.powershop.com.au" ;;
        uk) host="secure.powershop.co.uk" ;;
        *) echo "nz, uk, or au"
    esac

    for data_centre in wlg akl lon1 fra2 ; do
        if ([ `host "${host}"|cut -d" " -f4` "==" `host "${data_centre}.${host}"|cut -d" " -f4` ]); then
            echo "$data_centre"
            return
        fi
    done
}

nitra () {
    COUNTRY="$1" bundle exec nitra -c1 --debug --rspec "$2"
}

#Powershop functions
reset_test_db () {
  cp db/test_structure.sql db/structure.sql &&
    RAILS_ENV=test COUNTRY="$1" rake db:drop db:create db:structure:load db:migrate &&
    rm db/structure.sql &&
    echo "$fg_bold[green]Test db reset completed$reset_color"
}

#git aliases
alias gc="git commit -v"
alias ga="git add"
alias gs="git status"
alias gl="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias gd="git diff --word-diff=color"
alias gp="git push"
alias gco="git checkout"
alias pullff="git pull --ff"
alias fwl="git push --force-with-lease"

gshow ()
{
  git show ${1:null} --word-diff=color
}

gitlog ()
{
  git log master.. --format="%Cgreen[$(git symbolic-ref --short HEAD) %C(bold blue)%h] %C(green)%ar %C(bold blue)%an %Creset%s" --no-merges --reverse
}

commitlog ()
{
  git log master.. --format="%Cgreen[$(git symbolic-ref --short HEAD) %C(bold blue)%h] %Creset%s" --no-merges --reverse
}

# show next (newer) commit
git_next() {
    BRANCH=`git show-ref | grep $(git show-ref -s -- HEAD) | sed 's|.*/\(.*\)|\1|' | grep -v HEAD | sort | uniq`
    HASH=`git rev-parse $BRANCH`
    PREV=`git rev-list --topo-order HEAD..$HASH | tail -1`
    git show $PREV
}

# A more colorful prompt
# \[\e[0m\] resets the color to default color
c_reset='\[\e[0m\]'
#  \e[0;31m\ sets the color to red
c_path='\[\e[0;31m\]'
# \e[0;32m\ sets the color to green
c_git_clean='\[\e[0;32m\]'
# \e[0;31m\ sets the color to red
c_git_dirty='\[\e[0;31m\]'

# determines if the git branch you are on is clean or dirty
git_prompt ()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return 0
  fi
  # Grab working branch name
  git_branch=$(Git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
  # Clean or dirty branch
  if git diff --quiet 2>/dev/null >&2; then
    git_color="${c_git_clean}"
  else
    git_color=${c_git_dirty}
  fi
  echo " [$git_color$git_branch${c_reset}]"
}

#git auto completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

# Colors ls should use for folders, files, symlinks etc, see `man ls` and
# search for LSCOLORS
export LSCOLORS=ExGxFxdxCxDxDxaccxaeex
# Force ls to use colors (G) and use humanized file sizes (h)
alias ls='ls -Gh'

# Force grep to always use the color option and show line numbers - but it breaks fzf with color codes
# export GREP_OPTIONS='-n --color=always'

# PS1 is the variable for the prompt you see everytime you hit enter
PROMPT_COMMAND='PS1="${c_path}\W${c_reset}$(git_prompt) :> "'

# objc[90477]: +[NSFontCollection initialize] may have been in progress in another thread when fork() was called.
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export PS1='\n\[\033[0;31m\]\W\[\033[0m\]$(git_prompt)\[\033[0m\]:> 'export PATH="$HOME/.rbenv/bin:$PATH"

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# brew doctor complains if I don't have this
# export PATH="/usr/local/bin:$PATH"

# thefuck
eval "$(thefuck --alias fuck)"

# Exercism.io
if [ -f ~/.config/exercism/exercism_completion.bash ]; then
    source ~/.config/exercism/exercism_completion.bash
fi
export PATH="/usr/local/opt/mariadb@10.0/bin:$PATH"
