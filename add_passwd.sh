#!/bin/bash
source funciones.sh
# Sin pedir IP  --> Se ejecuta add_passwd $IP
#----------- GUARDAR VARIABLES ----------------
archivo=pass.conf
key=key
IFS=./ read -r i1 i2 i3 i4 mask <<<$1
leer_passwd
#----------------------------------------------
ccrypt -d -k $key $archivo
if [[ -z $mask ]]; then # Solo introducimos IP
    if [[ $(grep -c "\<$1\>" $archivo) -ne 0 ]]; then
        (grep -v "\<$1\>" $archivo && echo "IP = [$1] ; PASS = [$SECRET_PASSWD]") | sort >tmp.txt && cat tmp.txt >$archivo && rm tmp.txt
    else
        echo "IP = [$1] ; PASS = [$SECRET_PASSWD]" >>$archivo
        cat $archivo | sort >tmp.txt && cat tmp.txt >$archivo && rm tmp.txt
    fi
else                                             # Introducimos IP y máscara
    red=$(network $i1.$i2.$i3.$i4 $mask)         # Calculamos la red
    IFS=. read -r i1 i2 i3 i4 <<<$red            # Nos quedamos con la IP de la red
    broadcast=$(broadcast $i1.$i2.$i3.$i4 $mask) # Calculamos el broadcast
    IFS=. read -r b1 b2 b3 b4 <<<$broadcast      # Guardamos la IP del broadcast
    netmask=$(netmask $mask)                     # Convertimos la máscara en formato A.B.C.D
    networkIP=()                                 # Creamos un array para guardar las IP de la red
    m=0
    for ((i = $i1; i <= $b1; i++)); do # Guardamos todas las IP de la red en el array
        for ((j = $i2; j <= $b2; j++)); do
            for ((k = $i3; k <= $b3; k++)); do
                for ((h = $i4; h <= $b4; h++)); do
                    networkIP[$m]=$i.$j.$k.$h # Guardo las IP de la red
                    if [[ $m -ne 0 ]]; then
                        if [[ $(grep -c "\<${networkIP[$m]}\>" $archivo) -ne 0 ]]; then
                            (grep -v "\<${networkIP[$m]}\>" $archivo && echo "IP = [${networkIP[$m]}] ; PASS = [$SECRET_PASSWD]") | sort >tmp.txt && cat tmp.txt >$archivo && rm tmp.txt
                        else
                            echo "IP = [${networkIP[$m]}] ; PASS = [$SECRET_PASSWD]" >>$archivo
                            cat $archivo | sort >tmp.txt && cat tmp.txt >$archivo && rm tmp.txt
                        fi
                    fi
                    let m++
                done
            done
        done
    done
fi
ccrypt -e -k $key $archivo