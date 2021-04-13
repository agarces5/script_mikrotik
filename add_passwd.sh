#!/bin/bash
source funciones.sh
# Leer IP y password
read -p "Introduzca la IP del equipo: " nueva_IP
leer_passwd
ccrypt -d -k key pass.conf
if [[ $(grep -c "\<$nueva_IP\>" pass.conf) -ne 0 ]]; then
    (grep -v "\<10.0.0.1\>" pass.conf && echo "IP = [$nueva_IP] ; PASS = [$SECRET_PASSWD]") | sort > tmp.txt && cat tmp.txt > pass.conf && rm tmp.txt 
else
    echo "IP = [$nueva_IP] ; PASS = [$SECRET_PASSWD]" >> pass.conf
    cat pass.conf | sort > tmp.txt && cat tmp.txt > pass.conf && rm tmp.txt 
fi

ccrypt -e -k key pass.conf


# No funciona bien cuando hay contraseñas vacias
# if [[ $(grep -c "\<$nueva_IP\>" pass.conf) -ne 0 ]]; then
#     old_pass=`grep "\<$nueva_IP\>" pass.conf | awk '{print $NF}' | sed -e 's/\[//; s/\]//'` #Filtramos la contraseña antigua
#     echo $old_pass
#     sed "/\<$nueva_IP\>/ s/$old_pass/$SECRET_PASSWD/g" pass.conf #> tmp.txt && cat tmp.txt > pass.conf && rm tmp.txt 
# else
#     echo No hace nada
# fi