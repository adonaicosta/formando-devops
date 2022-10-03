# Observações
Quando você cria uma AMI e inicia uma nova instância, exceto o volume do EBS, todas as outras configurações importantes desaparecem, como VPC, sub-redes, grupos de segurança e tipo da instância.
A solução é buscar esses dados da instância original na AWS e depois usá-los para criar a nova instância.