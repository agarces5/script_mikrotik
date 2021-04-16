#!/bin/bash
source funciones.sh
#Inicializar variables
user=admin
DIA=$(date +"%d/%m/%Y-")
HORA=$(date +"%H:%M:%S")
#---------------------------------------------------------------------------------------------------------------------
#--------------------------------- COMIENZO DEL SCRIPT ---------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------
resp=$(echo $* | grep -w "y$" | awk '{print $NF}')
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
if [[ -z $mask && -z $script && -z $passwdFile ]]; then
    leer_passwd
    ejecutar_comando -p $SECRET_PASSWD $user $IP $comando 2>>log.txt
elif [[ -z $mask && -z $script && -n $passwdFile ]]; then
    pass=$(ccrypt -c -k key $passwdFile | grep "\<$IP\>" | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
    ejecutar_comando -p $pass $user $IP $comando 2>>log.txt
    unset pass
elif [[ -z $mask && -n $script && -z $passwdFile ]]; then
    leer_passwd
    ejecutar_script -p $SECRET_PASSWD $script $user $IP 2>>log.txt
elif [[ -z $mask && -n $script && -n $passwdFile ]]; then
    pass=$(ccrypt -c -k key $passwdFile | grep "\<$IP\>" | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
    ejecutar_script -p $pass $script $user $IP 2>>log.txt
    unset pass
elif [[ -n $mask ]]; then
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
        if [[ -n $script && -z $passwdFile ]]; then
            leer_passwd
            ejecutar_script -p $SECRET_PASSWD $script $user ${networkIP[$m]} 2>>log.txt
        elif [[ -n $script && -n $passwdFile ]]; then
            echo linea 69
            pass=$(ccrypt -c -k key $passwdFile | grep "\<${networkIP[$m]}\>" | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
            bool=$(ccrypt -c -k key $passwdFile | grep "\<${networkIP[$m]}\>")
            if [[ ! $bool ]]; then
                add_passwd ${networkIP[$m]} $pass
            fi
            ejecutar_script -p $pass $script $user ${networkIP[$m]} 2>>log.txt
            unset pass
        fi
        if [[ -n $comando && -n $passwdFile ]]; then
            pass=$(ccrypt -c -k key $passwdFile | grep "\<${networkIP[$m]}\>" | awk '{print $NF}' | sed -e 's/\[//; s/\]//')
            ejecutar_comando -p "$pass" "$user" "${networkIP[$m]}" 2>>log.txt
            unset pass
        elif [[ -n $comando && -z $passwdFile ]]; then
            leer_passwd
            ejecutar_comando -p $SECRET_PASSWD $user ${networkIP[$m]} 2>>log.txt
        fi
    done
fi
