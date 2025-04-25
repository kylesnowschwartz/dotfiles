alias reload="source ~/.bashrc"
alias be="bundle exec"
alias mkdir='mkdir -v'
alias ls='ls -AGghs'
alias cp='cp -v'
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"

rubymine()
{
open -a RubyMine "$@"
}

ss()
{
rfv "$@"
}

#pbcopy & pbpaste aliases
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"

#review
#alias review='open "https://github.com/envato/marketplace/compare/$(git symbolic-ref --short HEAD)"'
alias review='open "https://github.com/$(git remote get-url origin | sed -E "s/.*:(.+)\/(.+).git/\\1\/\\2/")/compare/$(git symbolic-ref --short HEAD)"'


alias prep="rails db:migrate db:test:prepare"

#git aliases
alias gc="git commit -v"
alias ga="git add"
alias gs="git status"
alias gl="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias gd="git diff"
alias gp="git push"
alias gco="git checkout"
alias pullff="git pull --ff"
alias fwl="git push --force-with-lease"
irebase() {
  local n=$1
  EDITOR=vim git rebase -i HEAD~$n
} 

#rails_upgrade
alias dn="DEPENDENCIES_NEXT=1"

## Envato Aliases

alias marketplace_server="MARKET_SOCKET_DIR=/tmp bundle exec unicorn_rails -c config/unicorn.rb"

# /aws accounts <account-id> # in slack

# aws-vault login Customer-Production.Developer
# aws-login Customer-Production.Developer
aws-login()
{
  aws-vault login $1
}

# takes a role as $1 e.g. Customer-Production.Developer, and then all the rest of the arguments as your command to be
# executed
aws-exec()
{
    aws-vault exec $1 -- ${@:2}
}

list-instances()
{
    ( echo -e "Instance ID\tPrivate IP\tAMI\tLaunch Time\tName\tRevision tag";
      aws ec2 describe-instances \
        --region $AWS_REGION \
        --filters Name=instance-state-name,Values=running \
        --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,ImageId,LaunchTime,not_null(Tags[?Key==`Name`].Value | [0], `<noname>`),not_null(Tags[?Key==`deployment.revision`].Value | [0], `<none>`)]' \
        --output text | sort -k5,5 \
    ) | column -s $'\t' -t
}

list_instances()
{
    list-instances
}

# Example stackmaster apply
# staging
# aws-exec cloudformation-user@envato-customer-staging bundle exec stack_master apply eu-west-1 shopfront_ext_alb_storefront_tg
# production
# aws exec cloudformation@envato-customer-production bundle exec stack_master apply us-east-1 shopfront_ext_alb_storefront_tg

# Opensearch
function opensearch() {
  JAVA_HOME="$(asdf where java zulu-17.46.19)" "$(asdf which opensearch)"
}

## End Envato Aliases
gshow ()
{
    git show ${1:null} --word-diff=color
}

gitlog ()
{
    git log main.. --format="%Cgreen[$(git symbolic-ref --short HEAD) %C(bold blue)%h] %C(green)%ar %C(bold blue)%an %Creset%s" --no-merges --reverse
}

# show next (newer) commit
git_next() {
    BRANCH=`git show-ref | grep $(git show-ref -s -- HEAD) | sed 's|.*/\(.*\)|\1|' | grep -v HEAD | sort | uniq`
    HASH=`git rev-parse $BRANCH`
    PREV=`git rev-list --topo-order HEAD..$HASH | tail -1`
    git show $PREV
}
