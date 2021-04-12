#!/bin/bash

#---------------------------------------------------------------------------------------------------------------------
#-------------------######  ##  ##  ##  ##   ####   ######   ####   ##  ##  ######   ####  ---------------------------
#-------------------##      ##  ##  ### ##  ##  ##    ##    ##  ##  ### ##  ##      ##     ---------------------------
#-------------------####    ##  ##  ## ###  ##        ##    ##  ##  ## ###  ####     ####  ---------------------------
#-------------------##      ##  ##  ##  ##  ##  ##    ##    ##  ##  ##  ##  ##          ## ---------------------------
#-------------------##       ####   ##  ##   ####   ######   ####   ##  ##  ######   ####  ---------------------------
#---------------------------------------------------------------------------------------------------------------------

#---------------- MENU DE AYUDA ----------------
help_menu()
{
    echo "---------------------- Menu de ayuda ----------------------"
    echo "-u [usuario]              ---> Para determinar el usuario (admin por defecto)"
    echo "-i [IP]                   ---> Para poner la IP (obligatorio)"
    echo "-s [ruta_script]          ---> Para poner el script"
    echo "-c [comando]              ---> Comando para ejecutar en el router (el comando entre '' o \"\") "
    echo "-p [ruta_file_passwd]     ---> Leer password desde fichero "
    echo "y (al final de la linea)  ---> Para que no pida confirmacion para reiniciar el router de fabrica antes de cargar un script"
    exit 1
}
#---------------- MOSTRAR ARGUMENTOS ----------------
mostrar_args(){
    echo "-----------------------------------------------------------"
    echo "El usuario es: $user"
    echo "La IP es: $IP"
    echo "El script es: $script"
    echo "El comando es: $comando"
    echo "El pass esta en: $passwdFile"
    echo "La resp es: $resp" 
}
#---------------- LEER PASSWD SEGURO ----------------
leer_passwd(){
    # -- Se guarda la configuracion de la sesion
    # stty actual.
    STTY_SAVE=`stty -g`
    stty -echo
    
    # -- Se solicita la introduccion del password al
    # usuario:
    echo
    echo -n "Introduzca su password: "
    read SECRET_PASSWD
    SECRET_PASSWD="-p $SECRET_PASSWD"
    # -- Se restablece la sesion stty anterior.
    stty $STTY_SAVE
    echo
}
#---------------- EJECUTAR SCRIPT ----------------
ejecutar_script(){
    if [[ -z $resp ]]; then
        read -p "¿Deseas restablecer de fabrica el router y cargar el script (yes/No)? " resp
    fi
    
    if [[ $resp == "yes" || $resp == "Yes"  || $resp == "y"  ]]; then
        echo "Restableciendo de fabrica y Ejecutando script"
        ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$IP"
        sshpass $1 $2 scp -o "StrictHostKeyChecking no" $script $user@$IP:configuracion.rsc
        sleep 5s
        sshpass $1 $2 ssh -o "StrictHostKeyChecking no" $user@$IP "system reset-configuration no-defaults=yes run-after-reset=configuracion.rsc"
    else
        echo "Ejecutando script"
        ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$IP"
        sshpass $1 $2 scp -o "StrictHostKeyChecking no" $script $user@$IP:configuracion.rsc
        sleep 5s
        sshpass $1 $2 ssh -o "StrictHostKeyChecking no" $user@$IP "import configuracion.rsc"
    fi
}
#---------------- EJECUTAR COMANDO ----------------
ejecutar_comando(){ 
    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$IP"
    sshpass $1 $2 ssh -o "StrictHostKeyChecking no" $user@$IP $comando 
}
