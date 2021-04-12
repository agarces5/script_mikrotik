#!/bin/bash
#Inicializar variables
no_input="No se ha introducido"
user=$no_input; script=$no_input; comando=$no_input; resp=$no_input; IP=$no_input;
password=`cat pass.conf`
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
    echo "-u [usuario]          ---> Para determinar el usuario (admin por defecto)"
    echo "-i [IP]               ---> Para poner la IP (obligatorio)"
    echo "-s [ruta_script]      ---> Para poner el script"
    echo "-c [comando]          ---> Comando para ejecutar en el router (el comando entre '' o \"\") "
    echo "-y ['yes'|'Yes'|'y']  ---> Para que no pida confirmacion para reiniciar el router de fabrica antes de cargar un script"
    exit 1
}
#---------------- MOSTRAR ARGUMENTOS ----------------
mostrar_args(){
    echo "-----------------------------------------------------------"
    echo "El usuario es: $user"
    echo "La IP es: $IP"
    echo "El script es: $script"
    echo "El comando es: $comando"
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
    
    # -- Se restablece la sesion stty anterior.
    stty $STTY_SAVE
    echo
}
#---------------- EJECUTAR SCRIPT ----------------
ejecutar_script(){
    if [[ $resp == $no_input ]]; then
        read -p "¿Deseas restablecer de fabrica el router y cargar el script (yes/No)? " resp
    fi
    
    if [[ $resp == "yes" || $resp == "Yes"  || $resp == "y"  ]]; then
        echo "Restableciendo de fabrica y Ejecutando script"
        scp $script $user@$IP:configuracion.rsc > /dev/null
        sshpass -p $SECRET_PASSWD ssh $user@$IP "system reset-configuration no-defaults=yes run-after-reset=configuracion.rsc"
    else
        echo "Ejecutando script"
        scp $script $user@$IP:configuracion.rsc > /dev/null
        sshpass -p $SECRET_PASSWD ssh $user@$IP "import configuracion.rsc"
    fi
}
#---------------- EJECUTAR COMANDO ----------------
ejecutar_comando(){ ssh $user@$IP $comando; }

#---------------------------------------------------------------------------------------------------------------------
#--------------------------------- COMIENZO DEL SCRIPT ---------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------

#Leer variables
while getopts u:i:s:c:y: flag
do
    case "${flag}" in
        u)  user=${OPTARG};;
        i)  IP=${OPTARG};;
        s)  script=${OPTARG};;
        c)  comando=${OPTARG};;
        y)  resp=${OPTARG};;
    esac
done

mostrar_args

if [[ $IP = $no_input ]]; then
    echo "-----------------------------------------------------------"
    echo "Debes introducir una direccion IP"
    echo
    help_menu
fi

if [[ $script != $no_input ]]; then
    leer_passwd
    ejecutar_script
fi
if [[ $comando != $no_input ]]; then
    leer_passwd
    echo "Ejecutando comando"
    ejecutar_comando
fi
