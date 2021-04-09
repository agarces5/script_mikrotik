#!/bin/bash

#Inicializar variables
init="No se ha introducido"
user=$init; IP=$init ;script=$init; comando=$init
let i=0

#Menu de ayuda
help_menu()
{
    echo "Menu de ayuda"
    echo "-u [usuario]          ---> Para determinar el usuario (admin por defecto)"
    echo "-i [IP]               ---> Para poner la IP (obligatorio)"
    echo "-s [ruta_script]      ---> Para poner el script"
    echo "-c [comando]          ---> Comando para ejecutar en el router (el comando entre '' o \"\") "
    exit 1
}
valido_ip=`echo $@ | grep '\-i'`
if [[ $@ = "" || -z $valido_ip ]]; then
    help_menu
fi
#Leer variables
while getopts u:i:s:c: flag
do
    case "${flag}" in
        u) user=${OPTARG};;
        i) IP=${OPTARG};;
        s) script=${OPTARG};;
        c) comando=${OPTARG};;

    esac
done

echo $user
echo $IP
echo $script
echo $comando
