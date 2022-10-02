#!/bin/bash
echo "Instalação de Pacotes"

if ! apt-get update
then 
    echo "Etapa 1: Não foi possível realizar a atualizacao dos repositorios"
    exit 1
fi

echo "Etapa 1: Os repositorios foram atualizados"
sleep 3

echo "Etapa 2: Digite o nome do pacote que deseja instalar"
read pkg_to_install


