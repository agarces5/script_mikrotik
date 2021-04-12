#!/bin/bash

    echo "---------------------- Menu de ayuda ----------------------"
    echo "1) Encriptar"
    echo "2) Desencriptar"
    read -p "Opcion: " opt

    case "$opt" in
        1) ccrypt -e -k key pass.conf
        ;;
        2) ccrypt -d -k key pass.conf
        ;;
    esac
