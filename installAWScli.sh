#!/bin/sh

retval=1
baseOS=NULL

function ifProgExists(){
    echo "checking existence for $1"
    # check via other methods too
    $1 --version 
    if [ $? -eq 0 ]
    then
        echo "$1 present."
        retval=0
    else
        echo "$1 : Not present"
        retval=1
    fi
}

function checkBase(){
    FILE="/etc/alpine-release"
    if [ -f "$FILE" ]
    then
    	echo "$FILE exist => Alpine system detected"
    	baseOS=alpine
    else
	baseOS=ubuntu
    fi
}

function pipInstall(){
	if [ "$baseOS" == "alpine" ]
	then
		echo "do pip cli install for alpine"
		apk add --no-cache python3
		if [ ! -e /usr/bin/python ] 
		    then ln -sf python3 /usr/bin/python
		fi 
                echo "**** install pip ****"
	        python3 -m ensurepip
	        rm -r /usr/lib/python*/ensurepip
	        pip3 install --no-cache --upgrade pip setuptools wheel
	        if [ ! -e /usr/bin/pip ]
	       	    then ln -s pip3 /usr/bin/pip
		fi
	else
		echo "do pip cli install for ubuntu"
	fi
}

function awscliInstall(){
    if [ $1 == "system" ]
    then
        echo "installing systemwide"
	pip3 install awscli --upgrade
    else
        echo "installing for current user"
	pip3 install awscli --upgrade --user
        export PATH=$PATH:$HOME/.local/bin
    fi
}

checkBase
ifProgExists aws
if [ $retval -ne 0 ]
then
    ifProgExists pip3
    if [ $retval -ne 0 ]
    then
	    echo "pip3 not found.  Installing pip3"
	    pipInstall
    fi
    echo "installing aws cli"
    awscliInstall "system"
else
    echo "aws cli already installed!"
fi
