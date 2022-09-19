Obs: não consegui encontrar nenhuma questão que fosse preciso tirar print, pois as questões e a forma de fazer me pareceram bem autoexplicativas.

# Desafio AWS

1 - Setup de ambiente

Execute os mesmos passos de criação de ambiente descritos anteriormente, porém atenção: dessa vez utilize o arquivo "formandodevops-desafio-aws.json"

    export STACK_FILE="file://formandodevops-desafio-aws.json"
    aws cloudformation create-stack --region us-east-1 --template-body "$STACK_FILE" --stack-name "$STACK_NAME" --no-cli-pager
    aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"
    
  
2 - Networking

A página web dessa vez não está sendo exibida corretamente. Verifique as configurações de rede que estão impedindo seu funcionamento.

    -> O SecurityGroup estava com a configuração das portas errada (range 81 - 8080) e o httpd executa por padrão na 80
    -> O Cidr também estava errado, algo que já dava pra descobrir pelo próprio json usado pra criar o stack
    
    
3 - EC2 Access

  Para acessar a EC2 por SSH, você precisa de uma key pair, que não está disponível. Pesquise como alterar a key pair de uma EC2.
  
    -> Criei outra instancia EC2 na mesma zona de disponibilidade
    -> Desassociei o volume da instância do desafio e associei com a nova EC2
    -> Criei um novo par de chaves e coloquei no volume
    -> Associei o volume de volta
    -> Habilitei a porta 22 no SecurityGroup
    
    

  Após trocar a key pair

  3.1 - acesse a EC2:

    ssh -i [sua-key-pair] ec2-user@[ip-ec2]
    

  3.2 - Altere o texto da página web exibida, colocando seu nome no início do texto do arquivo "/var/www/html/index.html".
  
    -> sed -i '1 i<h1>SEU NOME<h1>' /var/www/html/index.html
    
  ![img](https://github.com/Siluryan/Formando-Devops/blob/main/aws-expert/printdesafioaws.png)
    

4 - EC2 troubleshooting

No último procedimento, A EC2 precisou ser desligada e após isso o serviço responsável pela página web não iniciou. Encontre o problema e realize as devidas alterações para que esse serviço inicie automaticamente durante o boot da EC2.

    -> systemctl enable httpd
    

5 - Balanceamento

Crie uma cópia idêntica de sua EC2 e inicie essa segunda EC2. Após isso, crie um balanceador, configure ambas EC2 nesse balancedor e garanta que, mesmo com uma das EC2 desligada, o usuário final conseguirá acessar a página web.

    -> Criei uma imagem da instância do desafio
    -> Criei uma nova EC2 com essa imagem em outra zona de disponibilidade
    -> Coloquei as duas EC2 num Target Group
    -> Criei um Application Load Balancer a partir desse grupo
    

6 - Segurança

Garanta que o acesso para suas EC2 ocorra somente através do balanceador, ou seja, chamadas HTTP diretamente realizadas da sua máquina para o EC2 deverão ser barradas. Elas só aceitarão chamadas do balanceador e esse, por sua vez, aceitará conexões externas normalmente.

    -> Desabilitei a porta 80 no SecurityGroup das EC2
