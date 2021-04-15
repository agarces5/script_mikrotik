#!/bin/bash
source funciones.sh
#Inicializar variables
user=admin
#---------------------------------------------------------------------------------------------------------------------
#--------------------------------- COMIENZO DEL SCRIPT ---------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------
resp=$(echo $* | grep -iw "y$" | awk '{print $NF}')
#Leer variables
while getopts u:i:s:c:p: flag; do
    case "${flag}" in
    u) user=${OPTARG} ;;
    i) IP=${OPTARG} ;;
    s) script=${OPTARG} ;;
    c) comando=${OPTARG} ;;
    p) passwdFile=${OPTARG} ;;
    esac
done
mostrar_args
if [[ -z $IP ]]; then
    echo "-----------------------------------------------------------"
    echo "Debes introducir una direccion IP"
    echo
    help_menu
fi
if [[ -z $script && -z $comando ]]; then
    echo "No has introducido ni script ni comando"
fi
IFS=./ read -r i1 i2 i3 i4 mask <<<$IP
if [[ -z $mask ]]; then
    if [[ -n $script ]]; then
        if [[ -n $passwdFile ]]; then
            pass=$(ccrypt -c -k key pass.conf | grep $IP | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
            ejecutar_script -p $pass $script $user $IP
            unset pass
        else
            leer_passwd
            ejecutar_script -p $SECRET_PASSWD $script $user $IP
        fi
    fi
    if [[ -n $comando ]]; then
        if [[ -n $passwdFile ]]; then
            pass=$(ccrypt -c -k key pass.conf | grep $IP | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
            ejecutar_comando -p $pass $user $IP $comando
            unset pass
        else
            leer_passwd
            ejecutar_comando -p $SECRET_PASSWD $user $IP $comando
        fi
    fi
else
    red=$(network $i1.$i2.$i3.$i4 $mask)
    IFS=. read -r i1 i2 i3 i4 <<<$red
    broadcast=$(broadcast $i1.$i2.$i3.$i4 $mask)
    IFS=. read -r b1 b2 b3 b4 <<<$broadcast
    netmask=$(netmask $mask)
    networkIP=()
    m=0
    networkIP[0]=$red
    for ((i = $i1; i <= $b1; i++)); do
        for ((j = $i2; j <= $b2; j++)); do
            for ((k = $i3; k <= $b3; k++)); do
                for ((h = $((i4 + 1)); h <= $b4; h++)); do
                    let m++
                    networkIP[$m]=$i.$j.$k.$h # Guardo las IP de la IP
                done
            done
        done
    done
    for ((m = 1; m < $((${#networkIP[@]} - 1)); m++)); do
        # echo ${networkIP[$m]}
        if [[ -n $script ]]; then
            if [[ -n $passwdFile ]]; then
                pass=$(ccrypt -c -k key pass.conf | grep ${networkIP[$m]} | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
                ejecutar_script -p $pass $script $user ${networkIP[$m]}
                unset pass
            else
                leer_passwd
                ejecutar_script -p $SECRET_PASSWD $script $user ${networkIP[$m]}
            fi
        fi
        if [[ -n $comando ]]; then
            if [[ -n $passwdFile ]]; then
                pass=$(ccrypt -c -k key pass.conf | grep ${networkIP[$m]} | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
                ejecutar_comando -p $pass $user ${networkIP[$m]} $comando
                unset pass
            else
                leer_passwd
                ejecutar_comando -p $SECRET_PASSWD $user ${networkIP[$m]} $comando
            fi
        fi
    done
fi
