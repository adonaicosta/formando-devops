#!/bin/bash
pacote=$(dpkg --get-selections | grep $install_pkgs ) 
echo 
echo -n "Verificando se o Pacote $install_pkgs esta instalado."
sleep 2
if [ -n "$pacote" ] ;
then echo
     echo "Pacote $install_pkgs ja instalado"
     echo "Removendo e instalando a nova versao"
     sudo apt-get remove $install_pkgs
     sudo apt-get install $install_pkgs=$version_pkgs

else echo
     echo "Pacote $install_pkgs nao esta instalado"
     echo "Saindo..."     
fi
exit
