#!/bin/bash

# Leer script y ejecutar linea a linea por ssh

{
while IFS= read -r linea
do
    if [[ `echo $linea | grep "^#"` ]]; then
        continue
    fi
    echo $linea >> datos.dat
done
} < conf.rsc
cat datos.dat | tr '\n' ' ' | sed 's/ \//\n\//g'
rm datos.dat