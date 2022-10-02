#!/bin/bash
pacote=$(dpkg --get-selections | grep $uninstall_pkg ) 
echo 
echo -n "Verificando se o Pacote $uninstall_pkg esta instalado."
sleep 2
if [ -n "$pacote" ] ;
then echo
     echo "Pacote $uninstall_pkg esta instalado"
     echo "Removendo Automaticamente..."

else echo
     echo "Pacote $uninstall_pkg nao instalado"
     echo "Nada a fazer"     
fi
exit