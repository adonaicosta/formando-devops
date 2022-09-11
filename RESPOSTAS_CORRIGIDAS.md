## 1. Kernel e Boot loader

O usuário `vagrant` está sem permissão para executar comandos root usando `sudo`.
Sua tarefa consiste em reativar a permissão no `sudo` para esse usuário.

Dica: lembre-se que você possui acesso "físico" ao host.

    Bootloader é um software que permite a inicialização do sistema operacional de todos os dispositivos como computadores,
    smartphones, tablets e diversos equipamentos. Sempre que o dispositivo é ligado, ele irá acionar o bootloader para
    carregar o sistema operacional. Além disso, o software também funciona como garantia, caso ocorra alguma falha crítica
    com este sistema.
    
    Um exemplo de como um bootloader funciona é em dispositivos Cisco, que armazena as configurações na variável de ambiente
    BOOT, presente na ROM do equipamento e que você pode visualizar com o comando set, e mesmo alterar o caminho da imagem
    da inicialização do sistema em caso de corrompimento ou outro tipo de problema, desde que tenha acesso físico ao
    dispositivo.
    
    Na tarefa em questão está sendo solicitado para alterar a permissão sudo do usuário vagrant, mas como não foi informado
    nenhuma senha de acesso ao sistema isso deve ser feito pelo bootloader do linux, o GRUB. O GRUB passa algumas informações
    para o kernel, isto é, o núcleo do sistema operacional. Algumas dessas informações são: o sistema de arquivos do root,
    o tipo de montagem de uma partição, entre outros. 
    
    No caso da máquina do desafio, o GRUB tentará carregar o arquivo do kernel que está em /boot/vmlinuz-versão como usuário
    root (super usuário), em modo de leitura (ro, read only) e sem escrever na tela (quiet). Para ser possível fazer 
    alterações no sistema, a imagem precisa carregar também em modo de escrita (rw, read and write) e o caminho do arquivo
    de inicialização precisa ser alterado para que seja possível acessar as linhas de comando através do shell, como se já
    estivéssemos logados. Aqui pode ser indicado qualquer shell que já venha compilado na imagem. Para informar o novo path
    de boot, uso o comando init=/bin/bash.
     
    A partir desse momento, posso me certificar de que realmente estou no console como usuário root com o comando "whoami",
    além de conferir os comandos que estão disponíveis no shell informado com a linha "man builtins", e seguir com as
    modificações. Não é possível usar o comando visudo nesse modo, mas de maneira geral seu uso é recomendado para editar 
    o arquivo /etc/sudoers, pois ele verifica se há erros de sintaxe ao salvá-lo. O arquivo não será salvo se houver erros.
    Se você abrir o arquivo com um editor de texto diferente, um erro de sintaxe pode resultar na perda do acesso ao sudo.
    Outro detalhe importante é que o comando visudo não pode permitir a edição do arquivo /etc/sudoers simultaneamente, 
    apenas travando o arquivo e se alguém tentar acessar o mesmo, receberá uma mensagem para tentar mais tarde.
    
    Regras do sudoers:    
    -> username    hosts=(users:groups)    commands   

    Se você deseja usar o comando sem senha, use o parâmetro PASSWD:   
    -> username    ALL=(ALL:ALL)    NOPASSWD:ALL

    No exemplo abaixo, o usuário apenas inicia, interrompe e reinicie o serviço "httpd":
    -> username    ALL=(root)      /usr/bin/systemctl, /usr/sbin/httpd start stop restart
    
    Portanto para dar ao usuário vagrant a permissão de executar comandos root usando sudo, a seguinte linha deve ser
    escrita no sudoers:
    -> vagrant     ALL=(ALL:ALL)    ALL     
    

## 2. Usuários

### 2.1 Criação de usuários

Crie um usuário com as seguintes características:

- username: `getup` (UID=1111)
- grupos: `getup` (principal, GID=2222) e `bin`
- permissão `sudo` para todos os comandos, sem solicitação de senha

        Apesar de não ter sido especificado a função desse usuário no sistema, um set mínimo de configurações deve ser aplicado, tendo em
        vista tanto o princípio de privilégios mínimos quanto a boas práticas de criação de usuários. Sendo assim, esse usuário deve ser
        criado sem um diretório, uma vez que pode se tratar apenas de uma conta de gerenciamento.
        Ainda no bash que foi iniciado pelo grub, alguns comandos precisam ser indicados com o path inteiro para que possam ser executados,
        e para saber o caminho de um determinado comando a sintaxe é "whereis comando". Além disso, algumas flags precisam acompanhar esse
        comando:
        
        -> /usr/sbin/useradd -M -U -G bin getup && /usr/sbin/groupmod -g 2222 getup

        Onde:

        useradd    
        -M garante que um diretório NÃO seja criado para o novo usuário
        -U cria o grupo inicial do usuário com o mesmo nome (importante caso a varíável de ambiente não esteja configurada para fazer isso)
        -G adiciona o usuário a um grupo extra, no caso o grupo bin

        group
        -g alera o gid do grupo especificado

        Além disso, o arquivo sudoers também deve ser modificado para não pedir senha para esse usuário ao usar o comando sudo:    
        ->  getup    ALL=(ALL:ALL)    NOPASSWD:ALL
    

## 3. SSH

### 3.1 Autenticação confiável

O servidor SSH está configurado para aceitar autenticação por senha. No entanto esse método é desencorajado
pois apresenta alto nivel de fragilidade. Voce deve desativar autenticação por senhas e permitir apenas o uso
de par de chaves.


### 3.2 Criação de chaves

Crie uma chave SSH do tipo ECDSA (qualquer tamanho) para o usuário `vagrant`. Em seguida, use essa mesma chave
para acessar a VM.    

    Quando o cliente SSH inicia a autenticação de cliente (enviando uma chave pública e uma assinatura para o servidor SSH),
    o servidor SSH deve ser capaz de verificar se ele foi configurado com a mesma chave pública recebida do cliente.

    Portanto, a próxima etapa é configurar o servidor SSH com a chave pública. Duas subetapas são necessárias:

    Transfira o arquivo de chave pública para o host no qual o servidor SSH reside.
    Configure o servidor SSH com a chave pública.    
 
    Deve-se transferir o arquivo de chave pública para o host no qual o servidor SSH reside. Embora essa seja uma chave pública,
    é necessário escolher um método seguro para transferir o arquivo de chave pública. Por exemplo, é possível usar uma sessão de
    Secure FTP (SFTP) ou colocar o arquivo em alguma mídia física e ter a chave transferida com segurança.

    Dependendo da plataforma, da implementação e da configuração do servidor SSH, cada servidor pode ter alguns requisitos diferentes
    para configurar a chave pública. Como um exemplo, no transporte OpenSSH de SSH disponível no Red Hat Linux por padrão, a chave
    pública é anexada ao arquivo $HOME/.ssh/authorized_keys, em que $HOME é o diretório inicial do ID do usuário no qual o cliente
    SSH efetua logon. Por exemplo, se você configurasse o cliente SSH com um ID do usuário vagrant, o caminho para o arquivo
    authorized_keys poderia ser: /home/vagrant/.ssh/authorized_keys.

    Etapas envolvidas na configuração do servidor SSH:

    1 - Certifique-se de estar logado como vagrant no host no qual o servidor SSH reside
    2 - Mude para o diretório inicial para vagrant
    3 - Crie o diretório .ssh em /home/vagrant.
    4 - Verifique as configurações de permissão para .ssh
    5 - Mude as configurações de permissão de .ssh para rwx------
    6 - Verifica as novas configurações de permissão para .ssh
    7 - Mude para o diretório .ssh 
    8 - Anexe o arquivo de chave pública ao arquivo authorized_keys
    9 - Verifique as configurações de permissão para authorized_keys
    10 - Muda as configurações de permissão de authorized_keys para rw-------
    11 - Verifica as novas configuraçoes de permissão para authorized_keys
    12 - É possível excluir vagrant.id_ecdsa.pub a partir desse momento
    
    2 - cd /home/vagrant
    3 - mkdir .ssh
    4 - ls -la 
    5 - chmod 700 .ssh
    6 - ls -la
    7 - cd .ssh
    8 - cat vagrant.id_ecdsa.pub >> authorized_keys
    9 - ls -l
    10 - chmod 600 authorized_keys
    11 - ls -l
    12 - rm vagrant.id_ecdsa.pub    

### 3.3 Análise de logs e configurações ssh

Utilizando a chave do arquivo [id_rsa-desafio-linux-devel.gz.b64](id_rsa-desafio-linux-devel.gz.b64) deste repositório, acesse a VM com o usuário `devel`.

Dica: o arquivo pode ter sido criado em um SO que trata o fim de linha de forma diferente.

## 4. Systemd

Identifique e corrija os erros na inicialização do servico `nginx`.
Em seguida, execute o comando abaixo (exatamente como está) e apresente o resultado.
Note que o comando não deve falhar.

```
curl http://127.0.0.1
```

Dica: para iniciar o serviço utilize o comando `systemctl start nginx`.

## 5. SSL

### 5.1 Criação de certificados

Utilizando o comando de sua preferencia (openssl, cfssl, etc...) crie uma autoridade certificadora (CA) para o hostname `desafio.local`.
Em seguida, utilizando esse CA para assinar, crie um certificado de web server para o hostname `www.desafio.local`.

### 5.2 Uso de certificados

Utilizando os certificados criados anteriormente, instale-os no serviço `nginx` de forma que este responda na porta `443` para o endereço
`www.desafio.local`. Certifique-se que o comando abaixo executa com sucesso e responde o mesmo que o desafio `4`. Voce pode inserir flags no comando
abaixo para utilizar seu CA.

```
curl https://www.desafio.local
```

## 6. Rede

### 6.1 Firewall

Faço o comando abaixo funcionar:

```
ping 8.8.8.8
```

### 6.2 HTTP

Apresente a resposta completa, com headers, da URL `https://httpbin.org/response-headers?hello=world`

## 7. Logs

Configure o `logrotate` para rotacionar arquivos do diretório `/var/log/nginx`

## 8. Filesystem

### 8.1 Expandir partição LVM

Aumente a partição LVM `sdb1` para `5Gi` e expanda o filesystem para o tamanho máximo.

### 8.2 Criar partição LVM

Crie uma partição LVM `sdb2` com `5Gi` e formate com o filesystem `ext4`.

### 8.3 Criar partição XFS

Utilizando o disco `sdc` em sua todalidade (sem particionamento), formate com o filesystem `xfs`.
