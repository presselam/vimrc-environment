#!/usr/bin/env bash
#
# Title: installBundles.sh
# Descr: 
# Date : 2022-6-8
# Ver  : 1.0

source "$HOME/bin/common.sh"

declare -A BUNDLES=( \
  ['Jenkinsfile-vim-syntax']='https://github.com/martinda/Jenkinsfile-vim-syntax.git' \
  ['ale']='https://github.com/dense-analysis/ale.git' \
  ['tagbar']='https://github.com/preservim/tagbar.git' \
  ['vim-airline']='https://github.com/vim-airline/vim-airline' \
  ['vim-fugitive']='https://github.com/tpope/vim-fugitive.git' \
  ['vimoutliner']='https://github.com/vimoutliner/vimoutliner.git' \
)

#BINDIR=$(readlink -f "$(dirname "$0")")
BUNDLEDIR="$HOME/.vim/bundle"

if [[ ! -d "$BUNDLEDIR" ]]; then
  mkdir "$BUNDLEDIR"
fi  

pushd "${BUNDLEDIR}" || exit

for b in "${!BUNDLES[@]}"
do
  message "Loading ${b}"
  if [[ -d "${BUNDLEDIR}/${b}" ]]; then
    pushd "${BUNDLEDIR}/${b}" || exit 1
    git fetch
    git pull
    popd || exit 1
  else
    git clone "${BUNDLES[${b}]}"
  fi  
done
