#!/bin/bash

#---------------------------------------------------------------------------------------------------------------------
#-------------------######  ##  ##  ##  ##   ####   ######   ####   ##  ##  ######   ####  ---------------------------
#-------------------##      ##  ##  ### ##  ##  ##    ##    ##  ##  ### ##  ##      ##     ---------------------------
#-------------------####    ##  ##  ## ###  ##        ##    ##  ##  ## ###  ####     ####  ---------------------------
#-------------------##      ##  ##  ##  ##  ##  ##    ##    ##  ##  ##  ##  ##          ## ---------------------------
#-------------------##       ####   ##  ##   ####   ######   ####   ##  ##  ######   ####  ---------------------------
#---------------------------------------------------------------------------------------------------------------------

#---------------- MENU DE AYUDA ----------------
help_menu() {
    echo "---------------------- Menu de ayuda ----------------------"
    echo "-u [usuario]              ---> Para determinar el usuario (admin por defecto)"
    echo "-i [IP]                   ---> Para poner la IP (ej. 192.168.1.10) o una red (ej. 192.168.1.10/24"
    echo "-s [ruta_script]          ---> Para poner el script"
    echo "-c [comando]              ---> Comando para ejecutar en el router (el comando entre '' o \"\") "
    echo "-p [ruta_file_passwd]     ---> Leer password desde fichero "
    echo "y (al final de la linea)  ---> Reiniciar router de fabrica "
    exit 1
}
#---------------- MOSTRAR ARGUMENTOS ----------------
mostrar_args() {
    echo "-----------------------------------------------------------"
    echo "El usuario es: $user"
    echo "La IP es: $IP"
    echo "El script es: $script"
    echo "El comando es: $comando"
    echo "El pass esta en: $passwdFile"
}
add_passwd() {
    nueva_IP=$1
    SECRET_PASSWD=$2
    if [[ -z $@ ]]; then
        read -p "Introduzca la IP del equipo: " nueva_IP
        leer_passwd
    fi
    ccrypt -d -k key $passwdFile
    if [[ $(grep -c "\<$nueva_IP\>" $passwdFile) -ne 0 ]]; then
        (grep -v "\<$nueva_IP\>" $passwdFile && echo "IP = [$nueva_IP] ; PASS = [$SECRET_PASSWD]") | sort >tmp.txt && cat tmp.txt >$passwdFile && rm tmp.txt
    else
        echo "IP = [$nueva_IP] ; PASS = [$SECRET_PASSWD]" >>$passwdFile
        cat $passwdFile | sort >tmp.txt && cat tmp.txt >$passwdFile && rm tmp.txt
    fi

    ccrypt -e -k key $passwdFile
}
#---------------- LEER PASSWD SEGURO ----------------
leer_passwd() {
    # -- Se guarda la configuracion de la sesion
    # stty actual.
    STTY_SAVE=$(stty -g)
    stty -echo

    # -- Se solicita la introduccion del password al
    # usuario:
    echo
    echo -n "Introduzca su password: "
    read SECRET_PASSWD    
    add_passwd $IP $SECRET_PASSWD
    # -- Se restablece la sesion stty anterior.
    stty $STTY_SAVE
    echo
}
#---------------- EJECUTAR SCRIPT ----------------
ejecutar_script() {
    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$5"
    sshpass $1 $2 scp -o "StrictHostKeyChecking no" $3 $4@$5:configuracion.rsc
    sleep 5s
    if [[ -n $resp && -n $pass ]]; then
        sshpass $1 $2 ssh -o "StrictHostKeyChecking no" $4@$5 "system reset-configuration no-defaults=yes run-after-reset=configuracion.rsc"
    elif [[ -n $resp && -z $pass ]]; then
        ssh -o "StrictHostKeyChecking no" $4@$5 "system reset-configuration no-defaults=yes run-after-reset=configuracion.rsc"
    elif [[ -z $resp && -n $pass ]]; then
        sshpass $1 $2 ssh -o "StrictHostKeyChecking no" $4@$5 "import configuracion.rsc"
    elif [[ -z $resp && -z $pass ]]; then
        ssh -o "StrictHostKeyChecking no" $4@$5 "import configuracion.rsc"
    fi
}
#---------------- EJECUTAR COMANDO ----------------
ejecutar_comando() {
    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$4"
    if [[ -z $pass ]]; then
        ssh -o "StrictHostKeyChecking no" $3@$4 $comando
    else
        sshpass $1 $2 ssh -o "StrictHostKeyChecking no" $3@$4 $comando
    fi
}

#---------------- FUNCIONES PARA CALCULAR PARAMETROS DE LA RED ----------------
ipToint() { # PASAR UNA IP A ENTERO
    local a b c d
    { IFS=. read a b c d; } <<<$1
    echo $(((((((a << 8) | b) << 8) | c) << 8) | d)) #(((192*2^8+168)2^8)+0*2^8)+0=192*2^24+168*2^16+0*2^8+0
}
intToip() { # PASAR DE ENTERO A IP
    local ui32=$1
    shift
    local ip n
    for n in 1 2 3 4; do
        ip=$((ui32 & 0xff))${ip:+.}$ip
        ui32=$((ui32 >> 8))
    done
    echo $ip
}
netmask() { # CALCULAR MASCARA
    # Example: netmask 27 => 255.255.255.224
    local mask=$((0xffffffff << (32 - $1)))
    shift
    intToip $mask
}

broadcast() { # CALCULAR BROADCAST
    # Example: broadcast 192.168.0.0 27 => 192.168.0.31
    local addr=$(ipToint $1)
    shift
    local mask=$((0xffffffff << (32 - $1)))
    shift
    intToip $((addr | ~mask))
}

network() { # CALCULAR RED
    # Example: network 192.68.11.155 21 => 192.68.8.0
    local addr=$(ipToint $1)
    shift
    local mask=$((0xffffffff << (32 - $1)))
    shift
    intToip $((addr & mask))
}

