#!/bin/bash
source funciones.sh
#Inicializar variables
# no_input="No se ha introducido"
# user=$no_input; script=$no_input; comando=$no_input; resp=$no_input; IP=$no_input; passwdFile=$no_input;
user=admin
#---------------------------------------------------------------------------------------------------------------------
#--------------------------------- COMIENZO DEL SCRIPT ---------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------

resp=`echo $* | grep -iw "y$" | awk '{print $NF}'`
#Leer variables
while getopts u:i:s:c:p:r: flag
do
    case "${flag}" in
        u)  user=${OPTARG};;
        i)  IP=${OPTARG};;
        s)  script=${OPTARG};;
        c)  comando=${OPTARG};;
        p)  passwdFile=${OPTARG};;
        r)  red=${OPTARG};;
    esac
done
mostrar_args

if [[ -z $IP && -z $red ]]; then
    echo "-----------------------------------------------------------"
    echo "Debes introducir una direccion IP o una red"
    echo
    help_menu
fi

if [[ -z $script && -z $comando ]]; then
    echo "No has introducido ni script ni comando"
fi
if [[ -n $script ]]; then
    if [[ -n $passwdFile ]]; then
        pass=`ccrypt -c -k key $passwdFile | grep "\<$IP\>" | awk '{print $NF}' | sed -e 's/\[//; s/\]//'`
        echo ejecutar_script -p $pass
        unset pass
    else
        leer_passwd
        echo ejecutar_script -p $SECRET_PASSWD
    fi    
fi
if [[ -n $comando ]]; then
    if [[ -n $passwdFile ]]; then
        echo ejecutar_comando $passwdFile
    else
        leer_passwd
        echo ejecutar_comando $SECRET_PASSWD
    fi    
fi
