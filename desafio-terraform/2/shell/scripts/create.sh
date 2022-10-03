#!/bin/bash
pacote=$(dpkg --get-selections | grep ${install_pkgs}) 
echo 
echo -n "Verificando se o Pacote ${install_pkgs} esta instalado."
sleep 2
if [ -n "$pacote" ] ;
then echo
     echo "Pacote ${install_pkgs} consta como instalado"
     echo "Reinstalando..."
     sudo apt-get remove ${install_pkgs}      
     sudo apt-get install ${install_pkgs}
else echo
     echo "Pacote $install_pkg nao esta instalado"
     echo "Instalando Automaticamente..."
     sudo apt-get install ${install_pkgs}
fi
exit
