#!/bin/bash
pacote=$(dpkg --get-selections | grep $install_pkg ) 
echo 
echo -n "Verificando se o Pacote $install_pkg esta instalado."
sleep 2
if [ -n "$pacote" ] ;
then echo
     echo "Pacote $install_pkg ja instalado"
     echo "Removendo e instalando a nova versao"
     sudo apt-get remove $install_pkg
     sudo apt-get install $install_pkg=$version_pkg

else echo
     echo "Pacote $install_pkg nao esta instalado"
     echo "Saindo..."     
fi
exit