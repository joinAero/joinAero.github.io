#!/bin/bash
echo "\033[32minstall \033[35mhexo-deployer-git\033[0m"
npm install hexo-deployer-git --save
echo "\033[32minstall themes\033[0m"
cd themes/; sh themes.sh; cd ..
exit 0
