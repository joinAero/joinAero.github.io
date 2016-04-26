#!/bin/bash

theme="hexo-theme-next"
repo="https://github.com/iissnan/${theme}"

dest="next"

if [[ -a "$dest" ]]; then
    if [[ -d "$dest" ]]; then
        echo -e "\033[32mgit pull \033[35m${theme}\033[0m"
        cd $dest; git pull $repo; cd ..
    else
        echo -e "\033[31m${dest} is not a directory\033[0m"
        exit 1
    fi
else
    echo -e "\033[32mgit clone \033[35m${theme}\033[0m"
    git clone $repo $dest
fi

exit 0
