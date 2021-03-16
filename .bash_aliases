alias reload="source ~/.bashrc"
alias be="bundle exec"
alias mkdir='mkdir -v'
alias ls='ls -gsh --color'
alias cp='cp -v'
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"

#pbcopy & pbpaste aliases
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"

#Powershop aliases
alias wipdb="RAILS_ENV=development DB_NAME=powershop_production DB_USER=wip MYSQL_SERVER=127.0.0.1 MYSQL_PORT=3324"
# usage: ssh <wip-ssh-name> -N -v -L 3324:maria:3306
# wipdb <country> rails c
alias review='xdg-open "https://git.fluxfederation.com/powerapps/powershop/compare/master...$(git symbolic-ref --short HEAD)"'

alias jira='xdg-open "https://jira.powershophq.com/browse/$(git symbolic-ref --short HEAD)"'
alias ci='xdg-open "https://ci.fluxfederation.com/job/coreapp-branch-only/job/$(git symbolic-ref --short HEAD)"'

alias audeploy='xdg-open "https://deployer.test.powershop.com.au"'
alias nzdeploy='xdg-open "https://deployer.test.powershop.co.nz"'
alias ukdeploy='xdg-open "https://deployer.test.powershop.co.uk"'
alias merxdeploy='xdg-open "https://wippy.merx.fluxfederation.com/"'

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

alias ukprodlon="ssh uk-prod-app-lon1-d10"
alias ukprodfra="ssh uk-prod-app-fra2-d10"
alias nzprodakl="ssh nz-prod-app-akl1-d10"
alias nzprodwlg="ssh nz-prod-app-wlg1-d10"
alias auprodakl="ssh au-prod-app-akl1-d10"
alias auprodwlg="ssh au-prod-app-wlg1-d10"
alias merxprodwlg="ssh merx-prod-app-wlg1-d1"
alias merxprodakl="ssh merx-prod-app-akl1-d1"

alias prep="rails db:migrate db:test:prepare"

active () {
    case "$1" in
        nz) host="secure.powershop.co.nz" ;;
        au) host="secure.powershop.com.au" ;;
        uk) host="secure.powershop.co.uk" ;;
        merx) host="active.merx.fluxfederation.net" ;;
        *) echo "valid arguments are one of: merx, nz, uk, or au"
    esac

    for data_centre in wlg akl lon1 fra2 ; do
        if [ "$host" == "active.merx.fluxfederation.net" ]
        then
            active_host="${data_centre}.merx.fluxfederation.net"
        else
            active_host="${data_centre}.${host}"
        fi

        if ([ `host "${host}"|cut -d" " -f4` "==" `host "${active_host}"|cut -d" " -f4` ]); then
            echo "$data_centre"
            return
        fi
    done
}

nitra () {
    COUNTRY="$1" bundle exec nitra -c1 --debug --rspec "$2"
}

#git aliases
alias gc="git commit -v"
alias ga="git add"
alias gs="git status"
alias gl="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias gd="git diff --color=always | less -r"
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

# Prompt settings
source ~/.git-prompt.sh
PROMPT_COMMAND='__git_ps1 "\w" "\\\$ "'
GIT_PS1_SHOWCOLORHINTS=1
