#!/usr/bin/env bash
#
# Title: quick.sh
# Descr: 
# Date : 2026-8-25
# Ver  : 1.0

source "$HOME/bin/common.sh"

BINDIR=$(readlink -f "$(dirname "$0")")


git checkout main 2>/dev/null || git checkout master      
git pull                                                 
                                                        
git submodule update --init --recursive                
                                                      
git submodule foreach '                              
  git fetch origin >/dev/null 2>&1                  
                                                   
  # Try main first, then master                   
  if git rev-parse --verify origin/main >/dev/null 2>&1; then        
    branch=main                                                     
  elif git rev-parse --verify origin/master >/dev/null 2>&1; then  
    branch=master                                                 
  else                                                           
    echo "No main/master in $name, skipping"                    
    exit 0                                                     
  fi                                                          
                                                             
  git checkout "$branch"                                    
  git pull origin "$branch"                                
'                                                         
                                                         
# Record updated submodule commits                      
git add .                                              
git commit -m "Update submodules to latest main/master" 
git push

