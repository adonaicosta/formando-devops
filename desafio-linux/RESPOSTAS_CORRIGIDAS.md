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
    de boot, insiro a linha init=/bin/bash logo após o parâmetro quiet. Quando já estiver na linha de comando e quiser reiniciar
    a máquina eu preciso executar o comando init que está localizado na pasta /sbin/init: exec /sbin/init 6.
     
    A partir desse momento, posso me certificar de que realmente estou no console como usuário root com o comando "whoami",
    além de conferir os comandos que estão disponíveis no shell informado com a linha "man builtins", e seguir com as
    modificações. De maneira geral é recomendado editar o arquivo /etc/sudoers utilizando o visudo, pois ele verifica se
    há erros de sintaxe ao salvá-lo. O arquivo não será salvo se houver erros. Se você abrir o arquivo com um editor de
    texto diferente, um erro de sintaxe pode resultar na perda do acesso ao sudo. Outro detalhe importante é que o comando
    visudo não pode permitir a edição do arquivo /etc/sudoers simultaneamente, travando o arquivo e se alguém tentar acessar
    o mesmo, além de receber uma mensagem para tentar mais tarde.
    
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

        Apesar de não ter sido especificado a função desse usuário no sistema, um set mínimo de configurações deve ser
        aplicado, tendo em vista tanto o princípio de privilégios mínimos quanto a boas práticas de criação de usuários.
        Sendo assim, esse usuário deve ser criado sem um diretório próprio, uma vez que pode se tratar apenas de uma conta
        de gerenciamento.
        
        Ainda no Bash que foi iniciado pelo GRUB, alguns comandos precisam ser indicados com o path inteiro para que possam
        ser executados, e para saber o caminho de um determinado comando a sintaxe é "whereis comando". Além disso, algumas
        flags precisam acompanhar esse comando:
        
        -> /usr/sbin/useradd -M -U -G bin getup && /usr/sbin/groupmod -g 2222 getup

        Onde:

        useradd    
        -M garante que um diretório NÃO seja criado para o novo usuário
        -U cria o grupo inicial do usuário com o mesmo nome (importante caso a varíável de ambiente não esteja configurada para fazer isso)
        -G adiciona o usuário a um grupo extra, no caso o grupo bin

        group
        -g altera o gid do grupo especificado

        Além disso, o arquivo sudoers também deve ser modificado para não pedir senha para esse usuário ao usar o comando sudo:    
        ->  getup    ALL=(ALL:ALL)    NOPASSWD:ALL
    

## 3. SSH

### 3.1 Autenticação confiável

O servidor SSH está configurado para aceitar autenticação por senha. No entanto esse método é desencorajado
pois apresenta alto nivel de fragilidade. Voce deve desativar autenticação por senhas e permitir apenas o uso
de par de chaves.

    O sshd_config é o arquivo de configuração do serviço ssh para o módulo servidor. Abaixo estao indicadas
    algumas das opções de configuração desse arquivo: 
     
 
    Port 22 : Porta padrão usada pelo servidor sshd
    
    
    ListenAddress 192.168.0.x :  Especifica o endereço IP das interfaces de rede que o servidor sshd
                                 servirá requisições


    Protocol 2 :  Protocolos aceitos pelo servidor, primeiro será verificado se o cliente é
                  compatível com a versão 2 e depois a versão 1. Caso seja especificado somente
                  a versão 2 e o cliente seja versão 1, a conexão será descartada.
                  Quando não é especificada, o protocolo ssh 1 é usado como padrão.    

    
    HostKey /etc/ssh/ssh_host_rsa_key : Especifica os arquivos que contém as chaves privadas do sshd.               
                                        O ssh faz a criptograifa dos dados usando chaves assimétricas   
                                        privadas e públicas.                                       
    
    
    UsePrivilegeSeparation yes : Está opção especifica se será criado um processo filho sem privilégios.   
                                 Após a autenticação bem-sucedida, outro processo será criado que tem    
                                 o privilégio de o usuário autenticado. O objetivo da separação de      
                                 privilégio é para evitar a escalonamento de privilégios. A opcao 
                                 padrão é "Sim". 
                     
    
    KeyRegenerationInterval 1200 : Tempo para geração de nova chave do servidor (segundos). O padrão é  
                                   3600 segundos (1 hora).                                                  
                                   O propósito de regeneração de chaves é para evitar descriptografar           
                                   trafégo capturado em sessões abertas para posteriormente tentar           
                                   invadir a máquina e roubar as chaves.                               
                                   A chave nunca é armazenada em qualquer lugar. Se o valor for 0           
                                   a chave nunca será regenerada.                                 
  
    
    ServerKeyBits 1024 : Tamanho da chave após ser gerada. 1024 bits é o padrão.   

    
    SyslogFacility AUTH : Indica Facilidade e nível logs do sshd que aparecerão no syslogd   
    LogLevel INFO         ou no rsyslog, e podem ser alterados conforme a necessídade.  
    
    
    LoginGraceTime 120 : Tempo máximo para fazer login no sistema antes da conexão ser fechada   
                         informado em segundos. Se o valor for 0 não tem limite.           
                         O padrão é 120 segundos.          

    
    PermitRootLogin no : Permite (yes) ou nega (no) que o usuário root acesse    
                         remotamente o servidor. por segurança deixe desabilitada.  

    
    PermitTunnel yes : Especifica se o encaminhamento pelos dispositivos tun/tap   
                       é permitido, criando um rede ponto-a-ponto usando ssh.           
                       Ou seja, permite ou não a criação de túneis cifrados com sshd. 

    
    StrictModes yes : Checa por permissões de dono dos arquivos e diretório de usuário antes de   
                      fazer o login. É muito recomendável para evitar riscos de segurança              
                      com arquivos lidos por todos os usuários.                        
  
    
    AllowUsers Nome_do_usuario : Usuários que o ssh permite acessar remotamente o servidor . 

    
    DenyUsers root : Está opção especifica quais usuários não terão permissão de acesso ao servidor
                     sshd. a sintaxe é a mesma de AllowUsers, pode especificar vários usuários   
                     separados por espaço.  
                      
    
    AllowGroups : Especifica uma lista de groupos que terão acesso permitido ao sshd.      
                                                        
    
    DenyGroups :  Especifica uma lista de grupos que terão seu acesso negado ao sshd.           
                  
    
    RSAAuthentication yes :  Especifica se a autenticação via RSA é permitida (só usado na versão 1 do   
                             protocolo ssh). Por padrão "yes".                                  

    
    PubkeyAuthentication yes : Especifica se a autenticação usando chave pública é permitida.  
                               O padrão é "Sim". Note que esta opção se aplica ao protocolo   
                               versão 2 apenas.    

    
    AuthorizedKeysFile  %h/.ssh/authorized_keys : Especifica o arquivo que contém as chaves públicas que podem ser usados
                                                  para autenticação de usuários. "%h" especifica o diretório home do          
                                                  do usuário que está usando as chaves públicas e privadas.  
                                                    
    
    IgnoreRhosts yes : Ignora os arquivos ~/.rhosts e ~/.shosts ou não.                                        
   
    
    PermitEmptyPasswords no : Se a opção PasswordAuthentication for usada, permite (yes) ou não (no) login   
                              sem senha. O padrão é "no". Não é recomendado habilitar (yes) essa opção   

    
    ChallengeResponseAuthentication no : Está opção permite (yes) ou nega (no) se a autenticação desafio-resposta será aceita   
                                         via PAM, por exemplo. O padrão é (yes).                               
    
    
    PasswordAuthentication yes : Se a PasswordAuthentication for usada, permite (yes) ou não (no) login 
                                  usando senha. O padrão é "yes".                          
  
    
    TCPKeepAlive yes : Permite (yes) ou não (no) o envio de pacotes keepalive (para verificar se o           
                       cliente responde. Isto é bom para fechar conexões que não respondem mas   
                       também podem fechar conexões caso não existam rotas para o cliente      
                       naquele momento. Colocando esta opção como "no", por outro lado, pode deixar
                       usuários que não tiveram a oportunidade de efetuar o logout do servidor de dados
                       como "permanentemente conectados" no sistema.                     

    
    UseLogin no :  Usa (yes) ou não usa (no) o programa login para efetuar o login do cliente 
                   no servidor ssh. o padrão é "não".                                                   

    
    MaxAuthTries 2 :   Especifica o número máximo de tentativas de autenticação permitidas   
                       por conexão. Uma vez que o número de falhas chega a metade desse   
                       valor, falhas adicionais são registrados. O padrão é 6.              

    
    MaxSessions 1 : Especifica o número máximo de sessões abertas permitidas. O padrão é 10.                         
   
    
    MaxStartups 5:40:15 :  Especifica o número máximo de conexões de autenticação simultâneas feitas   
                           pelo daemon sshd. O valor padrão é 10. Valores aleatórios podem ser      
                           especificados usando os campos "inicio:taxa:máximo". Por exemplo,             
                           5:40:15 rejeita até 40% das tentativas de autenticação que excedam o      
                           limite de 5 até atingir o limite máximo de 15 conexões, quando                      
                           nenhuma nova autenticação é permitida.                                       

    
    Banner /etc/issue.net : Mostra uma mensagem antes do nome de login.

   
   AcceptEnv LANG LC_* : Permitir que o cliente passe variáveis de ambiente de local
    
    
    Subsystem sftp /usr/lib/openssh/sftp-server -> Ativa o subsistema de ftp seguro.

    
    UsePAM no :  Permite a autenticação usando o PAM (yes) ou não (no). 
                  O padrão é "não".  
    

    Essa tarefa exige apenas a alteração do arquivo /etc/ssh/sshd_config e a reinicialização do daemon do ssh:
    
    PasswordAuthentication no
    

### 3.2 Criação de chaves

Crie uma chave SSH do tipo ECDSA (qualquer tamanho) para o usuário `vagrant`. Em seguida, use essa mesma chave
para acessar a VM.

    Chaves SSH são uma forma segura de identificar usuários conhecidos, substituindo o "usuário e senha".
    Sua vantagem está na quantidade de caracteres em relação à uma senha tradicional, fazendo com que ataques
    bruteforce sejam inviabilizados devido ao tempo absurdo necessário para se "encontrar" a chave secreta
    através de tentativa e erro.

    Esta chave pode ser gerada tanto no Windows quanto no Linux, e são um "par", sendo a chave pública
    (enviada para os servidores que você possui permissão para acessar) e a chave privada (somente você deve
    possuir e pode ser criptografada com uma senha). Você pode adicionar a sua chave pública a mais de um usuário
    ou até mesmo em servidores diferentes, desde que você utilize sua chave privada para entrar nestes servidores
    (a qual por padrão fica salva em seu usuário no Linux).
    
    
    Tipos de Algorítmos
    
    rsa - um algoritmo antigo baseado na dificuldade de fatorar números grandes. Um tamanho de chave de pelo menos
    2048 bits é recomendado para RSA; 4096 bits é melhor. A RSA está ficando velha e avanços significativos estão sendo
    feitos no factoring. A escolha de um algoritmo diferente pode ser aconselhável. É bem possível que o algoritmo RSA
    se torne praticamente quebrável no futuro próximo. Todos os clientes SSH suportam este algoritmo.

    dsa - um antigo algoritmo de assinatura digital do governo dos EUA. Baseia-se na dificuldade de calcular logaritmos
    discretos. Um tamanho de chave de 1024 normalmente seria usado com ele. O DSA em sua forma original não é mais recomendado.

    ecdsa - um novo algoritmo de assinatura digital padronizado pelo governo dos EUA, usando curvas elípticas. Este é
    provavelmente um bom algoritmo para aplicações atuais. Apenas três tamanhos de chave são suportados: 256, 384 e 521 bits.
    Recomenda-se sempre usá-lo com 521 bits, pois as chaves ainda são pequenas e provavelmente mais seguras do que as chaves menores
    (mesmo que elas também devam ser seguras). A maioria dos clientes SSH agora oferece suporte a esse algoritmo.

    ed25519 - este é um novo algoritmo adicionado no OpenSSH. O suporte para ele em clientes ainda não é universal.
    Assim, seu uso em aplicações de uso geral pode ainda não ser aconselhável.
    
    
    Como afirmado durante a correção das atividades, um cuidado que precisa ser tomado é sobre o uso de diversas
    chaves no mesmo diretório: se no momento da criação da chave não for indicada a saída apropriada uma chave
    de mesmo nome pode ser sobrescrita. Normalmente, a ferramenta cria um nome genérico para o arquivo no qual
    a chave é armazenada. No entanto, ele também pode ser especificado na linha de comando usando a opção -f (filename).
    
    -> ssh-keygen -f nome_da_chave -t ecdsa -b 521
    
    Obs: na flag -f também é possível indicar o caminho absoluto da nova chave junto com o nome:
         
    -> ssh-keygen -f /diretorio/nome_da_chave    
    
    Utilizando o Linux (no seu computador local, e não em seu servidor), você pode copiar a chave para o servidor utilizando 
    o comando abaixo:
    
    -> ssh-copy-id vagrant@ip-do-servidor
    
    Lembre-se de alterar o usuário e o servidor para qual a chave será copiada. Após realizado este procedimento, sua chave
    já estará instalada e você poderá logar no usuário e hosts especificado apenas usando o comando:

    ssh vagrant@ip-do-servidor
    
    
    Servidor OpenSSH (caso não estivesse previamente configurado)
    
    Para rodar um servidor OpenSSH, você deve primeiramente certificar-se de ter os pacotes RPM apropriados instalados.
    O pacote openssh-server é necessário e depende do pacote openssh. O daemon OpenSSH usa o arquivo de configuração
    /etc/ssh/sshd_config. O arquivo de configuração default deve ser suficiente na maioria dos casos.
    
    Para iniciar o serviço OpenSSH, use o comando /sbin/service sshd start. Para parar o servidor OpenSSH, use o comando
    /sbin/service sshd stop. Se você executar uma reinstalação e houver clientes conectados ao sistema com alguma
    ferramenta OpenSSH antes da reinstalação, os usuários cliente verão uma mensagem de WARNING.

    O sistema reinstalado cria um novo conjunto de chaves de identificação, apesar do aviso sobre a mudança da chave RSA
    da máquina. Se você deseja guardar as chaves geradas para o sistema, faça um backup dos arquivos /etc/ssh/ssh_host*key*
    e armazene-os após a reinstalação. Este processo retém a identidade do sistema e, quando os clientes tentarem conectar
    o sistema após a reinstalação, não receberão a mensagem de aviso.
    
    Quando o cliente SSH inicia a autenticação de cliente (enviando uma chave pública e uma assinatura para o servidor SSH),
    o servidor SSH deve ser capaz de verificar se ele foi configurado com a mesma chave pública recebida do cliente.
    Portanto, a próxima etapa é configurar o servidor SSH com a chave pública. Duas subetapas são necessárias:

    -> Transfira o arquivo de chave pública para o host no qual o servidor SSH reside.
    -> Configure o servidor SSH com a chave pública.    
 
    Deve-se transferir o arquivo de chave pública para o host no qual o servidor SSH reside. Embora essa seja uma chave pública,
    é necessário escolher um método seguro para transferir o arquivo de chave pública. Por exemplo, é possível usar uma sessão de
    Secure FTP (SFTP) ou colocar o arquivo em alguma mídia física e ter a chave transferida com segurança.

    Dependendo da plataforma, da implementação e da configuração do servidor SSH, cada servidor pode ter alguns requisitos
    diferentes para configurar a chave pública. Como um exemplo, no transporte OpenSSH de SSH disponível no Red Hat Linux,
    a chave pública é anexada ao arquivo $HOME/.ssh/authorized_keys, em que $HOME é o diretório inicial do ID do usuário
    no qual o cliente SSH efetua logon. Por exemplo, se você configurasse o cliente SSH com um ID do usuário vagrant,
    o caminho para o arquivo authorized_keys poderia ser: /home/vagrant/.ssh/authorized_keys.

    Etapas envolvidas na configuração do servidor SSH:

    1 - Certifique-se de estar logado como vagrant no host no qual o servidor SSH reside
    2 - Mude para o diretório inicial para vagrant
    3 - Crie o diretório .ssh em /home/vagrant
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

    Um arquivo é enviado pela Internet (normalmente usando uma API) como uma representação de cadeia de caracteres
    codificada em Base64. Ao permitir que os usuários convertam facilmente um arquivo em uma cadeia de caracteres
    Base64 e vice-versa, a transferência de arquivos pela Internet é facilitada. Nesse processo de codificação,
    os dados binários são convertidos em ASCII. Encode Base64 é uma codificação muito usada para transmitir
    dados binarios em forma de texto, ou tambem para ofuscar dados onde não seja necessario tanta segurança.
    
    Para decodificar um arquivo de texto codificado, teremos que usar a opção –decode ou -d:
    
    -> base64 -d id_rsa-desafio-linux-devel.gz.b64 > id_rsa-desafio-linux-devel.gz
    
    O comando gzip pode ser utilizado como uma ferramenta de compressão de arquivos no Unix.
    Seu uso é simples, e a flag -d indica que queremos a descompactação:
    
    -> gzip -d id_rsa-desafio-linux-devel.gz > id_rsa-desafio-linux-devel    
     
    
    Nos arquivos em formato DOS, o fim da linha é representado por dois caracteres, o Carriage Return (CR)
    ou \r seguido por Line Feed (LF) ou \n. Os arquivos Unix, por outro lado, usam apenas Line Feed \n.
    
    O comando tr é um comando básico no Linux/Unix, porém não é muito conhecido ou utilizado com frequência.
    Sua função básica é substituir (traduzir) o conteúdo de uma string (texto) recebido via entrada padrão
    (STDIN) de um formato para outro, ou ainda excluir caracteres. E para converter um arquivo com quebra
    de linha no padrão DOS para o padrão utilizado pelo Linux é simples:
    
    -> tr -d '\r' < id_rsa-desafio-linux-devel > id_rsa-desafio-linux-devel.unix   

    dos2unix é uma ferramenta para converter quebras de linha em um arquivo de texto do formato DOS para
    o formato UNIX e vice-versa.

    Comando dos2unix : converte um arquivo de texto DOS para o formato UNIX
    Comando unix2dos : converte um arquivo de texto Unix para o formato DOS
    
    
    Um dos erros identificados no log de autenticação por parte do cliente foi referente a GSSAPI, e vale a pena
    comentar sobre isso:
    
    A GSSAPI é uma interface que permite desenvolvedores escreverem aplicações que aproveitam mecanismos de segurança tais
    como Kerberos, sem ter de programar explicitamente para qualquer mecanismo, ou seja, aplicações genéricas do ponto de
    vista de segurança. Programas que usam GSSAPI são, deste modo, altamente portáteis, não somente de uma plataforma para
    outra, mas de uma configuração de segurança a outra e de um protocolo de transporte a outro.
    
    Poderia se argumentar que o erro na autenticação da chave seria por causa de um formato não compatível com essa API de
    autenticação, e caso não houvesse nenhuma política por parte da empresa nesse sentido seria possível dizer ao daemon
    do ssh para não solicitar esse tipo de compatibilidade alterando o seu arquivo de configuração e comentando as linhas
    correspondentes a GSSAPI.
    
    Apesar do desafio apresentar uma dica sobre a chave ter sido gerada em um sistema operacional e a tentativa de login ser
    em outro S.O., achei interessante simular como seria resolver esse desafio sem essa dica, e para isso usei a flag -vvv
    no lado do cliente para examinar mais detalhadamente o erro de autenticação.
    A linha mais relevante foi a que apontava um erro na biblioteca de criptografia do OpenSSH, que entre muitas funções
    possui opções de compatibilidade (incluindo compatibilidade para sistemas legados). Quando um cliente SSH se conecta
    a um servidor, cada lado oferece uma lista de parâmetros de conexão para o outro:

    -> KexAlgorithms: os métodos de troca de chaves que são usados para gerar uma conexão
    -> HostkeyAlgorithms: os algoritmos de chave pública aceitos por um servidor SSH para se autenticar em um cliente SSH
    -> Cifras: as cifras para criptografar a conexão
    -> MACs: os códigos de autenticação de mensagem usados para detectar a modificação do tráfego
    
    Para uma conexão bem-sucedida, deve haver pelo menos uma opção de suporte mútuo para cada parâmetro. Ou seja, como
    provavelmente o erro está na incompatibilidade da Cifra, as buscas por uma possível solução já poderiam ser reduzidas
    apenas para problemas comuns relacionados a isso.
    
    
## 4. Systemd

Identifique e corrija os erros na inicialização do servico `nginx`.
Em seguida, execute o comando abaixo (exatamente como está) e apresente o resultado.
Note que o comando não deve falhar.

```
curl http://127.0.0.1
```

Dica: para iniciar o serviço utilize o comando `systemctl start nginx`.

    Após emitir o comando systemctl start nginx, alguns erros são apresentados, e como o desafio indicava algo relacionado
    com o o Systemd (o primeiro log de erro aponta uma falha no carregamento do arquivo /usr/lib/systemd/system/nginx.service),
    o primeiro lugar que precisa ser analisado é esse arquivo. Um erro evidente é a flag -BROKEN que foi colocada intencionalmente
    para impedir a execução correta do programa, no entanto uma atitude mais adequada seria consultar um modelo do arquivo de
    configuração do nginx para descartar qualquer outra possibilidade de alteração, uma vez que uma flag apropriada, apesar de
    pertencer a biblioteca do arquivo, pode gerar um comportamento inesperado do serviço. Segue abaixo, portanto, um modelo
    retirado da própria página do nginx:
    
        [Unit]
        Description=The NGINX HTTP and reverse proxy server
        After=syslog.target network-online.target remote-fs.target nss-lookup.target
        Wants=network-online.target

        [Service]
        Type=forking
        PIDFile=/run/nginx.pid
        ExecStartPre=/usr/sbin/nginx -t
        ExecStart=/usr/sbin/nginx
        ExecReload=/usr/sbin/nginx -s reload
        ExecStop=/bin/kill -s QUIT $MAINPID
        PrivateTmp=true

        [Install]
        WantedBy=multi-user.target
        
    Logo após a remoção do parâmetro incorreto, é preciso recarregar o daemon do systemd para que ele reconheça
    a nova configuração da biblioteca do nginx com o comando systemctl daemon-reload.
    
    O systemd é um sistema de inicialização (init system) composto por um conjunto de programas executado em segundo
    plano (ou seja, um daemon). Atualmente, a maioria das distribuições Linux utilizam o systemd para execução do boot.
    Na prática, o systemd assume o controle assim que o kernel é ativado pelo gerenciador de bootloader (Grub, tipicamente).
    A partir daí, são carregados todos os dispositivos (placa de rede, processador gráfico etc.) e processos que se iniciam
    com o sistema — estes são identificados pelo PID (process identifier) e é o caso, por exemplo, do nginx.
    
    A flag -t do nginx indica que num primeiro momento é feito um teste de sintaxe e uma tentativa de carregar as
    informações presentes no arquivo arquivo de configuração, que é o /etc/nginx/nginx.conf. Como a saída
    do log já indicava um erro crítico nesse arquivo [emerg] a busca pelo motivo da falha na inicializacao do serviço
    deveria continuar por ali. O arquivo de configuracao do nginx é menos critico que o arquivo da biblioteca para se
    realizar alterações, e nesse caso posso simplesmente corrigir os erros de sintaxe presentes no arquivo e testar
    novamente o servico.        
        
  
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
