# Ejecutar script introduciendo argumentos

usuario=$1                         #Recomendado root
ip_remoto=$2
script_local=$3
echo "Usuario? $usuario"
echo "IP? $ip_remoto"
echo "Script? $script_local"
# read -p "Correcto? " conf
# if [[ $conf = n ]] 
# then
# exit
# fi

#ftp $ip_remoto

#ssh $usuario@$ip_remoto < $script_local  
ssh $usuario@$ip_remoto  #import $script_local