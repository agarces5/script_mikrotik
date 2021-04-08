#!/bin/bash

{
while IFS= read -r "lineNum"
do
    variables=${lineNum}
done
} <<< $@

let i=0
for VAR in $variables
do
    if   [[ $user == 1 ]]; then user=$VAR
    elif [[ $IP == 1 ]]; then IP=$VAR
    elif [[ $script == 1 ]]; then script=$VAR
    elif [[ $comando == 1 ]]; then comando=$VAR
    fi
    if   [[ $VAR == "-u" ]]; then user=1
    elif [[ $VAR == "-i" ]]; then IP=1
    elif [[ $VAR == "-s" ]]; then script=1
    elif [[ $VAR == "-c" ]]; then comando=1
    fi
done
echo $user
echo $IP
echo $script
echo $comando
