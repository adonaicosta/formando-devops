#!/bin/sh
#variaveis
echo "Hello World"
echo "O mantra sagrado não deve ser escrito de outra forma"
echo "Meu nome é ${nome} e estou participando do Desafio Terraform da Getup/LinuxTips."
#contadores
INDEX = 1
LISTA_INDEX = 0
CEM = 100
#divisores
while [ $INDEX -le $CEM ]; do
    if [ ($CEM/$INDEX) == 0 ]; then
    LISTA[$LISTA_INDEX] = $INDEX
    let INDEX=INDEX+1;
    let LISTA_INDEX=LISTA_INDEX+1;
    else
    let INDEX=INDEX+1;
    fi
done
#resultado
echo "Hoje é dia ${data} e os números de 1 a 100 divisíveis por ${div} são: $LISTA_INDEX"
