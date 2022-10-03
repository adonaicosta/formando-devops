# Observações

1. O desafio pedia para reinstalar um pacote que foi removido manualmente (fora do terraform) e o script "create.sh" reinstala o pacote mesmo que ele seja detectado no state (resolvendo o problema caso o pacote nao esteja na maquina apesar de estar no state).

2. A variável "install_pkgs" é passada como uma string para o script, e portanto os pacotes podem ser passados com ou sem versão, da mesma forma que eles seriam instalados num terminal comum. Ex: install_pkgs = "package1  package2-version1 package3-version3 package 4".

3. Para fazer update passe apenas um pacote por vez. Gostaria de ter tratado isso mas acredito que ainda não tenho conhecimento técnico ou vivência na área de tecnologia o suficiente para tratar isso a tempo.
