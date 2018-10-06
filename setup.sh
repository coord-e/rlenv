#!/usr/bin/env bash
readonly BD_EJECTED=true
readonly BD_CACHE="$HOME/.cache/bd"

if [ ! -d "$BD_CACHE" ]; then
  mkdir -p $BD_CACHE
fi

if [ -v BD_EJECTED ]; then
  BD_SCRIPT=$0
else
  BD_SCRIPT=$1
  shift
fi

BD_ARGS=($@)
BD_SCRIPT_NAME=$BD_SCRIPT

bd_total_progress=0
bd_current_progress=0

BD_DEFAULT_EJECTED_FUNCTIONS=()
BD_STARTUP_CODE=()

BD_LOG_LEVEL=${BD_LOG_LEVEL:-info}
name () 
{ 
    BD_SCRIPT_NAME=$1
}
description () 
{ 
    if [ -t 1 ]; then
        BD_SCRIPT_DESCRIPTION=$(cat);
    else
        BD_SCRIPT_DESCRIPTION=$@;
    fi
}
info () 
{ 
    log info "$@"
}
log () 
{ 
    local loglevel=$1;
    shift;
    local content=$@;
    declare -A level2num=([debug]=0 [info]=1 [warn]=2 [error]=3);
    if [ -z "${level2num[$BD_LOG_LEVEL]}" ]; then
        local invalid_one=$BD_LOG_LEVEL;
        BD_LOG_LEVEL=info;
        bd::logger::error_exit "Invalid log level \"$invalid_one\"";
    fi;
    if [ ${level2num[$loglevel]} -lt ${level2num[$BD_LOG_LEVEL]} ]; then
        return;
    fi;
    declare -A level2fmt=([debug]="\033[0;35m[DEBUG] \033[0m %s\n" [info]="\033[0;32m[INFO] \033[0m\033[0;01m %s\033[0;0m\n" [warn]="\033[0;33m[WARN] \033[0m\033[0;01m %s\033[0;0m\n" [error]="\033[0;31m[ERROR] \033[0m\033[0;01m %s\033[0;0m\n");
    printf "${level2fmt[$loglevel]}" "$content" 1>&2
}
bd::logger::error () 
{ 
    error "bd: $@"
}
error () 
{ 
    log error "$@"
}
bd::logger::error_exit () 
{ 
    error_exit "bd: $@"
}
error_exit () 
{ 
    error "$1";
    exit ${2:--1}
}
progress () 
{ 
    bd::store::load bd_current_progress bd_total_progress;
    bd_current_progress=$((bd_current_progress += 1));
    if [[ "$bd_total_progress" == "0" ]]; then
        local status="$(printf "%3d" $bd_current_progress).";
    else
        local percentage=$(( bd_current_progress * 100 / bd_total_progress ));
        local status="$(printf "%3d" $percentage)%";
    fi;
    local text="$1";
    echo -e "\033[0;32m $status -> \033[0m\033[0;01m $text\033[0;0m";
    if [[ $bd_current_progress -eq $bd_total_progress ]]; then
        bd_current_progress=0;
        bd_total_progress=0;
    fi;
    bd::store::save bd_total_progress bd_current_progress
}
bd::store::load () 
{ 
    for key in $@;
    do
        local path=$BD_CACHE/$key;
        if [ -f $path.ary ]; then
            path=$path.ary;
        else
            if [ ! -f $path ]; then
                bd::logger::warn "loading variable \"$key\", which is not defined";
            fi;
        fi;
        local value=$(cat $path);
        if [[ "$path" == *.ary ]]; then
            eval "$key=($value)";
        else
            eval "$key=\"$value\"";
        fi;
    done
}
bd::logger::warn () 
{ 
    warn "bd: $@"
}
warn () 
{ 
    log warn "$@"
}
bd::store::save () 
{ 
    for key in $@;
    do
        if [[ "$(declare -p $key)" =~ "declare -a" ]]; then
            local value=$(eval "echo \"\${$key[@]}\"");
            local path=$BD_CACHE/$key.ary;
        else
            if [ ! -v $key ]; then
                bd::logger::warn "saving variable \"$key\", which is not defined";
            else
                local value=$(eval "echo \"\$$key\"");
                local path=$BD_CACHE/$key;
            fi;
        fi;
        echo "$value" > $path;
    done
}
bd::store::save bd_total_progress bd_current_progress
#!/usr/bin/env bd


name "rlenv bootstrapping script"
description << EOF
Bootstrap the reinforcement learning project with rlenv.
Usually, this script is executed directly from curl/wget.
EOF


function pushd () {
  command pushd "$@" > /dev/null
}

function popd () {
  command popd "$@" > /dev/null
}

info "rlenv bootstrapping script"

progress "Initialize git and git-flow repository"

git init
git flow init

progress "Clone rlenv as a submodule"

git submodule add https://github.com/coord-e/rlenv
pushd rlenv
git submodule update --init --recursive
popd

# Obtain the hash of baselines/roboschool in rlenv, and add them as a submodule
function get_hash() {
  pushd rlenv/$1
  git rev-parse HEAD
  popd
}

function add_and_checkout() {
  git submodule add https://github.com/$1
  pushd $(basename $1)
  git checkout $2
  popd
}

function reclone_submodule() {
  repo=$1
  dir=$(basename $repo)
  hash_rlenv=$(get_hash $dir)
  add_and_checkout $repo $hash_rlenv
}

progress "Fetch submodules"

reclone_submodule openai/baselines
reclone_submodule openai/roboschool
reclone_submodule olegklimov/bullet3

progress "Copy template files"

cp rlenv/template/* .

progress "Install dependencies"

./setup.sh

progress "Commit changes"

git add .
git commit -m "Bootstrap with rlenv"

info "Done!"
