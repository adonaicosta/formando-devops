#!/bin/bash

pacote=$(dpkg --get-selections | grep $install_pkg ) 
echo 
echo -n "Verificando se o Pacote $install_pkg esta instalado."
sleep 2
if [ -n "$pacote" ] ;
then echo
     echo "Pacote $install_pkg ja instalado"
else echo
     echo "Pacote $install_pkg nao esta instalado"
     echo "Instalando Automaticamente..."
     sudo apt-get install $install_pkg
fi
exit