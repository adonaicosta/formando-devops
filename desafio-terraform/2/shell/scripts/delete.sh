#!/bin/bash
pacote=$(dpkg --get-selections | grep ${uninstall_pkgs}) 
echo 
echo -n "Verificando se o Pacote ${uninstall_pkgs} esta instalado."
sleep 2
if [ -n "$pacote" ] ;
then echo
     echo "Pacote ${uninstall_pkgs} esta instalado"
     echo "Removendo Automaticamente..."
     sudo apt-get remove ${uninstall_pkgs}

else echo
     echo "Pacote ${uninstall_pkgs} nao esta instalado"
     echo "Nada a fazer"     
fi
exit
