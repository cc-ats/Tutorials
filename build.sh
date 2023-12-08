#/bin/bash

if [ -e ~/.bash_aliases ]; then
    shopt -s expand_aliases
    source ~/.bash_aliases
    myconda
else
    exit
fi

jupyter-book build . --all

ghp-import -n -p -f _build/html
