#!/bin/bash

valido_ip=`echo $@ | grep '\-i'`
if [[ $@ = "" || -z $valido_ip ]]; then
    echo "Menu de ayuda"
    echo "-u [usuario]          ---> Para determinar el usuario (admin por defecto)"
    echo "-i [IP]               ---> Para poner la IP"
    echo "-s [ruta_script]      ---> Para poner el script"
    echo "-c [comando]          ---> Comando para ejecutar en el router"
    exit 1
fi

let i=0
user="admin"
for VAR in $@
do
    args[$i]=$VAR  #Guardo los argumentos
    let i++
done

# Asigno los argumentos que me interesan en variables
for ((i = 0; i < ${#args[*]}; i++)); do
    if [[  ${args[$i]} = -u ]]; then
        user=${args[$i+1]}
    fi
    if [[  ${args[$i]} = -i ]]; then
        ip=${args[$i+1]}
    fi
    if [[  ${args[$i]} = -s ]]; then
        script=${args[$i+1]}
    fi
    if [[  ${args[$i]} = -c ]]; then
        comando=${args[$i+1]}
    fi
done
echo "El usuario es: $user"
echo "La IP es: $ip"
echo "El script es: $script"
echo "El comando es: $comando"

# echo "Usuario? $usuario"
# echo "IP? $ip_remoto"
# echo "Script? $script_local"

#Formatear el archivo para poder mandar los comandos
{
while IFS= read -r linea
do
    if [[ `echo $linea | grep "^#"` ]]; then
        continue
    fi
    echo $linea >> datos.dat  #Lo guardo en un archivo temporal
done
} < $script
#Elimino los saltos de linea 
# cat datos.dat | sed 's/$/ \\/' | tr '\n' 'n' > formateado.txt
linea=`datos.dat`
echo $linea
ssh $user@$IP $linea
rm datos.dat                  #Borro el archivo temporal