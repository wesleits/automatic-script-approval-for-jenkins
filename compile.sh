#!/bin/bash

###########################################################################################
##### Script works correctly in Ubuntu 14.04/16.04                                    #####
##### To install this plugin execute in jenkins machine these commands:               #####
#####                                                                                 #####
##### wget -N https://goo.gl/KYzEzx -P /var/lib/jenkins/plugins --content-disposition #####
##### service jenkins restart                                                         ##### 
###########################################################################################


if [ ! -d ".git" ]
then
  #=== Elevate script to root if not is
  if [ $EUID != 0 ]
  then 
    sudo "$0" "$@"
  else
    #=== Install pre requisites
    apt-get update
    apt-get -y install wget
    apt-get -y install software-properties-common
    apt-get -y install vim

    #=== Install git
    add-apt-repository -y ppa:git-core/ppa
    apt-get update
    apt-get -y install git
    
    #=== Install JDK 8
    add-apt-repository -y ppa:webupd8team/java
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
    apt-get update
    apt-get install -y oracle-java8-installer
    
    #=== Install Maven 3
    apt-get purge maven maven2 maven3
    add-apt-repository ppa:andrei-pozolotin/maven3
    apt-get update
    apt-get -y install maven3
    
    exit $?
  fi

  #== initialize repository
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
   
git fetch
git checkout master
git merge

mvn package  # needs JDK 8 to compile plugin!!!!!!

#=== only push if the maven package does not to return some error
if [ $? -eq 0 ]
then
  cp ./target/automatic-script-approval-for-jenkins.hpi ./

  git add -A
  git reset "./target"
  git commit -m "$MESSAGE"
  git push -f
fi

read