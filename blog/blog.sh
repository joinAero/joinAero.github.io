#!/bin/bash

# https://google.github.io/styleguide/shell.xml

# Functions

npm_install() {
    for name in $*; do
        echo "\033[32minstall \033[35m${name}\033[0m"
        npm install $name --save
    done
}

npm_installed() {
    result=`npm list $1 --depth=0`
    if [[ "$result" =~ "$1" ]]; then
        return 0
    else
        return 1
    fi
}

npm_update() {
    if [[ $# -eq 0 ]]; then
        # echo "\033[32mnpm update -g\033[0m"
        # npm update -g
        echo "\033[32mnpm update\033[0m"
        npm update
    else
        for name in $*; do
            echo "\033[32mnpm update \033[35m${name}\033[0m"
            npm update $name
        done
    fi
}

npm_uninstall() {
    for name in $*; do
        echo "\033[32muninstall \033[35m${name}\033[0m"
        npm uninstall $name --save
    done
}

# Processing

process() {
    for module in $*; do
        npm_installed $module
        if [[ $? -eq 0 ]]; then
            npm_update $module
        else
            npm_install $module
        fi
    done
}

echo "\033[36mprepare modules extra\033[0m"
process "hexo-deployer-git hexo-generator-feed"

echo
echo "\033[36mupdate modules all\033[0m"
npm_update

echo
echo "\033[36mprepare themes\033[0m"
cd themes/; sh themes.sh; cd ..

exit 0
