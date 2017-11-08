#!/bin/bash

if [ ! -d ".git" ]
then
  git init
  git config --global core.editor "vim"
  git config --local core.sshCommand "ssh -i /var/tmp/weslei -o StrictHostKeyChecking=no"
  git remote add origin git@github.com:wesleits/automatic-script-approval-for-jenkins.git
  git config user.name "Weslei Teixeira da Silveira"
  git config user.email "wesleiteixeira@hotmail.com.br"
fi

if [ -z "$1" ]
then
  MESSAGE="scripts updated"
else
  MESSAGE=$1
fi
   
cp ./target/automatic-script-approval-for-jenkins.hpi ./plugin.hpi 2>/dev/null   
   
git fetch
git checkout master
git merge
git add -A
git reset "./target"
git commit -m "$MESSAGE"
git push -f
 
read