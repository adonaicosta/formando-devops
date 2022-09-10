## 1. Kernel e Boot loader

O usuário `vagrant` está sem permissão para executar comandos root usando `sudo`.
Sua tarefa consiste em reativar a permissão no `sudo` para esse usuário.

  Bootloader é um software que permite a inicialização do sistema operacional de todos os dispositivos como computadores, smartphones, tablets e diversos equipamentos. Sempre que o dispositivo é ligado, ele irá acionar o bootloader para carregar o sistema operacional. Além disso, o software também funciona como garantia, caso ocorra alguma falha crítica com este sistema.
  Um exemplo de como um bootloader funciona é em dispositivos Cisco, que armazena as configurações na variável de ambiente BOOT, presente na ROM do equipamento e que você pode visualizar com o comando set, e mesmo alterar o caminho da imagem da inicialização do sistema em caso de corrompimento ou outro tipo de problema, desde que tenha acesso físico ao dispositivo.
  Na tarefa em questão está sendo solicitado para alterar a permissão sudo do usuário vagrant, mas como não foi informado nenhuma senha de acesso ao sistema isso deve ser feito pelo bootloader do linux, o GRUB.
  O GRUB passa algumas informações para o kernel, isto é, o núcleo do sistema operacional. Algumas dessas informações são: o sistemas de arquivos do root, o tipo de montagem de uma partição, entre outros. No caso da máquina do desafio, o GRUB tentará carregar o arquivo do kernel que está em /boot/vmlinuz-versão como usuário root (super usuário), em modo de leitura (ro, read only) e sem escrever na tela (quiet).
  Para ser possível fazer alterações no sistema, a imagem precisa carregar também em modo de escrita (rw, read and write) e o caminho do arquivo de inicialização precisa ser alterado para que seja possível acessar as linhas de comando através do shell, como se já estivéssemos logados. Aqui pode ser indicado qualquer shell que já venha compilado na imagem. Para informar o novo path de boot, uso o comando init=/bin/bash.
  
  



Dica: lembre-se que você possui acesso "físico" ao host.

## 2. Usuários

### 2.1 Criação de usuários

Crie um usuário com as seguintes características:

- username: `getup` (UID=1111)
- grupos: `getup` (principal, GID=2222) e `bin`
- permissão `sudo` para todos os comandos, sem solicitação de senha

## 3. SSH

### 3.1 Autenticação confiável

O servidor SSH está configurado para aceitar autenticação por senha. No entanto esse método é desencorajado
pois apresenta alto nivel de fragilidade. Voce deve desativar autenticação por senhas e permitir apenas o uso
de par de chaves.

### 3.2 Criação de chaves

Crie uma chave SSH do tipo ECDSA (qualquer tamanho) para o usuário `vagrant`. Em seguida, use essa mesma chave
para acessar a VM.

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
