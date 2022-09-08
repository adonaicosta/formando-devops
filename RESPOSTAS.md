1. Kernel e Boot loader

	O usuário vagrant está sem permissão para executar comandos root usando sudo. Sua tarefa consiste em reativar a permissão no sudo para esse usuário.

	Dica: lembre-se que você possui acesso "físico" ao host.

		Opção (e) na seleção de boot
		Mudar de ro para rw na linha do kernel
		init=/sysroot/bin/sh -> logo a frente da opção rw
		chroot /sysroot -> muda o direotorio root para sysroot (ctrl + x)
		chroot /sysroot
		passwd root
		senha:p53kwpko
		touch /.autorelabel -> tornar o diretório confiável para o SELinux
		exit -> sair do chroot
		reboot	
	
		passwd vagrant [v53kwpko] -> para ser possível alternar entre usuários		
		usermod -aG wheel vagrant						
		
2. Usuários

	2.1 Criação de usuários
	
	Crie um usuário com as seguintes características:
	     ->	username: getup (UID=1111)
	     ->	grupos: getup (principal, GID=2222) e bin
	     ->	permissão sudo para todos os comandos, sem solicitação de senha.  	             
		     	               	             
		    adduser --uid 1111 getup
		    groupmod --gid 2222 getup
		    usermod -aG bin, wheel getup
		    passwd getup [g53kwpko]

		    vim /etc/sudoers (para não pedir senha ao usar o sudo)
		    %wheel ALL=NOPASSWD:ALL 

3. SSH

	3.1 Autenticação confiável
			
	O servidor SSH está configurado para aceitar autenticação por senha. No entanto esse método é desencorajado pois apresenta alto nivel de fragilidade.
	Voce deve desativar autenticação por senhas e permitir apenas o uso de par de chaves:
		
		vim /etc/ssh/ssh_config
		PermitRootLogin como 'no'
		PasswordAuthentication como 'no'			
	
	3.2 Criação de chaves

	Crie uma chave SSH do tipo ECDSA (qualquer tamanho) para o usuário vagrant. Em seguida, use essa mesma chave para acessar a VM:
		
		cd ~/.ssh
		ssh-keygen -t ecdsa -b 521
		ssh-copy-id host@localremoto	
	
	3.3 Análise de logs e configurações ssh

	Utilizando a chave do arquivos id_rsa-desafio-devel.gz.b64 deste repositório, acesso a VM com o usuário devel:
	
		tail -f /var/log/audit/audit.log
	
		1ª tentativa (publickey, gssapi-keyex, gssapi-with-mic)
			
		2ª tentativa (publickey)
				
		3ª tentativa (unable to load Private Key)
		
		A saída que encontrei para esse e outros problemas parecidos foi copiar manualmente as chaves para a pasta
		authorized_keys e aplicar a permissão 600, mas como fiz isso sem saber ao certo porque funcionava, segue a
		solução do colega Wesley Silva (linkedin.com/in/wesley-silva-49080059):
		
		"Pra resolver o problema da chave, você primeiro precisa descriptografar e descompactar o arquivo
		(base64 -d id_rsa-desafio-linux-devel.gz.b64 | gzip -d > id_rsa). Quando você for usar a chave pelo
		ssh, ele vai apresentar 2 problemas: o primeiro é que o formato da chave tá invalido; o segundo é que
		o arquivo authorized_keys vai tá com uma permissão muito alta na pasta devel no servidor. No log secure 
		do servidor é possível ver esse segundo problema, então primeiro você precisa dar permissão 600	pro arquivo
		authorized_keys. O problema da chave é a forma da quebra de linha. Existem duas formas de quebra de linha
		mais usuais, a carriage-return e a newline. A chave está com a carriage-return e deveria estar com a newline.
		Existem duas formas de corrigir isso: a primeira é copiando o arquivo com o mouse, de dentro do editor.
		A outra forma é trocar todos os carriage-return pelos os newline com o comando sed"
		
4. Systemd

	Identifique e corrija os erros na inicialização do servico nginx. Em seguida, execute o comando abaixo (exatamente como está) e apresente o resultado. Note que o comando não deve falhar.
	
	curl http://127.0.0.1
	
		Apesar de ter seguido o erro apresentado pelo comando "systemctl status nginx.service" e ter corrigido
		a sintaxe do arquivo /etc/nginx/nginx.conf (o que pude atestar depois com o comando "nginx -t"), o serviço ainda
		apresentava erros, no caso agora o binário /usr/sbin/nginx, e portanto tive que reinstalar o serviço (obs: acabei
		não explicando o porquê dessa decisão, mas segue abaixo junto com a referência):
		
		" 3 - Instalação e Configuração Segura de Sistemas:
			
			Uma vez estabelecidas as políticas de segurança apropriadas para a sua rede (conforme exposto na seção 2), 
			a etapa seguinte deve ser a configuração segura dos sistemas que estarão nessa rede.
			Caso não exista uma documentação atualizada que detalhe a configuração de alguns ou todos os sistemas em uso na sua rede,
			é aconselhável que estes sistemas sejam reinstalados observando-se as recomendações aqui expostas, ou, pelo menos,
			que a sua configuração seja revisada e a documentação correspondente atualizada.
			IMPORTANTE: um sistema só deverá ser conectado à Internet após os passos descritos nas seções 3.1 a 3.8 terem sido seguidos.
			A pressa em disponibilizar um sistema na Internet pode levar ao seu comprometimento ." 
			
			https://www.cert.br/docs/seg-adm-redes/seg-adm-redes.html#subsec2.2
		
					     yum remove nginx
					     yum install nginx
					     systemctl start nginx				     
					     
			Saída abreviada do comando curl http://127.0.0.1:
			
				<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

				<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
				    <head>
					<title>Test Page for the Nginx HTTP Server on Red Hat Enterprise Linux</title>
					<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
					.......................................................................
					.......................................................................
					.......................................................................
				    </head>

				    <body>
					<h1>Welcome to <strong>nginx</strong> on Red Hat Enterprise Linux!</h1>

					.......................................................................
					.......................................................................
					.......................................................................

					    <div class="logos">
						<a href="http://nginx.net/"><img
						    src="nginx-logo.png" 
						    alt="[ Powered by nginx ]"
						    width="121" height="32" /></a>
						<a href="http://www.redhat.com/"><img
						    src="poweredby.png"
						    alt="[ Powered by Red Hat Enterprise Linux ]"
						    width="88" height="31" /></a>
					    </div>
					</div>
				    </body>
				</html>		

5. SSL

	5.1 Criação de certificados

	Utilizando o comando de sua preferencia (openssl, cfssl, etc...) crie uma autoridade certificadora (CA) para o hostname desafio.local. Em seguida, utilizando esse CA para assinar, crie um certificado de web server para o hostname www.desafio.local.
	
		iptables -A INPUT -p tcp --dport 443 -j ACCEPT
		firewall-cmd --permanent --add-service=http
		firewall-cmd --permanent --add-service=https
		firewall-cmd --permanent --zone=public --add-port=443/tcp
		firewall-cmd --reload
		
		chmod -R 755 /usr/share/nginx
		yum install mod_ssl
		yum install openssl openssl-perl		
		mkdir /root/CA
		
		CA.pl -newca
		passphrase [c53kwpko]
		parâmetros : BR, SaoPaulo, SaoPaulo, Getup, FormandoDevops, desafio.local, desafio_local@getup.com
		cakey.pem [c53kwpko]
		
		CA.pl -newrq
		parâmetros: BR, SaoPaulo, SaoPaulo, Getup, FormandoDevops, www.desafio.local, desafio_local2@getup.com
		challenge password [vazio]
		
		CA.pl -sign
	
	5.2 Uso de certificados	

	Utilizando os certificados criados anteriormente, instale-os no serviço nginx de forma que este responda na porta 443 para o endereço www.desafio.local. Certifique-se que o comando abaixo executa com sucesso e responde o mesmo que o desafio 4. Voce pode inserir flags no comando abaixo para utilizar seu CA.

	curl https://www.desafio.local
	
		cp newcert.pem /etc/pki/ngix/
		cp newkey.pem /etc/pki/nginx/private/
		
		vim /etc/nginx/nginx.conf
		# descomentar a seção do Servidor TLS		
		ssl_certificate "/etc/pki/nginx/newcert.pem";
		ssl_certificate_key "/etc/pki/nginx/private/newkey.pem";
		sysmtemctl restart nginx
		
		! importante: no processo de criação da chave é exigido uma passphrase, mas o nginx não vai conseguir
		subir desse modo, e o que pode ser feito é remover a passphrase depois que a chave foi gerada:
		
		openssl rsa -in newkey.pem -out newkey.pem
		
		! outra informação importante é sobre o curl, que não aceitava a CA que eu havia criado, mas foi possível
		contornar isso usando a flag -k (que ignora esse problema). No entanto, tentei encontrar uma maneira de usar
		o comando sem a flag, e apesar de não ter conseguido, seguem os passos que eu tentei:
		
		cat newcert.pem newreq.pem > desafio.ssl		
		vim /etc/nginx/nginx.conf
		ssl_certificate "/etc/pki/nginx/desafio.ssl"
		systemctl restart nginx
		
6. Rede

	6.1 Firewall

	Faço o comando abaixo funcionar:

	ping 8.8.8.8

		O comando já estava funcionando na máquina do desafio, mas caso não estivesse uma solução seria acrescentar
		essa regra no firewall:

		iptables -A INPUT -p icmp --icmp-type 8 -s $WAN -j ACCEPT

	6.2 HTTP

	Apresente a resposta completa, com headers, da URL https://httpbin.org/response-headers?hello=world

		curl -i https://httpbin.org/response-headers?hello=world

		HTTP/2 200 
		date: Sun, 04 Sep 2022 07:23:14 GMT
		content-type: application/json
		content-length: 89
		server: gunicorn/19.9.0
		hello: world
		access-control-allow-origin: *
		access-control-allow-credentials: true

		{
		  "Content-Length": "89", 
		  "Content-Type": "application/json", 
		  "hello": "world"
		}

Logs

Configure o logrotate para rotacionar arquivos do diretório /var/log/nginx
	
		O log rotate já estava devidamente configurado, mas caso contrário os seguintes passos seriam necessários:
		
		yum install logrotate
		vim /etc/logrotate.conf (verificar se /etc/logrotate.d está na sessão "include")
		vim /etc/logrotate.d./nginx
		
			var/log/nginx/*.log {
			daily
			missingok
			rotate 10
			compress
			delaycompress
			notifempty
			create 0640 www-data adm
			sharedscripts
			postrotate
				invoke-rc.d nginx rotate >/dev/null 2>&1
			endscript
		}
		
		testando a configuração do logrotate:
			
			logrotate -d /etc/logrotate.conf -> força a execução do logrotate
			cat /var/lib/logrotate/logrotate.status -> mostra os arquivos rotacionados		

7. Filesystem
	
	7.1 Expandir partição LVM

	Aumente a partição LVM sdb1 para 5Gi e expanda o filesystem para o tamanho máximo.
	
	7.2 Criar partição LVM

	Crie uma partição LVM sdb2 com 5Gi e formate com o filesystem ext4.
	
		Nessa tarefa procurei aproveitar a partição que já iria criar no 7.2 para poder estender
		a partição LVM sdb1 para 5G, que tinha apenas 1G de tamanho e que já estava sem espaço.	
	
			fdisk /dev/sdb -> para criar uma partição extendida /dev/sdb2		
			mkfs.ext4 /dev/sdb2
			pvcreate /dev/sdb2
			vgextend data_vg /dev/sdb2
			lvextend -L 5G /dev/data_vg/data_lv
			umount /data
			e2fsck /dev/data_vg/data_lv
			resize2fs /dev/data_vg/data_lv
			mount /data

	7.3 Criar partição XFS

	Utilizando o disco sdc em sua todalidade (sem particionamento), formate com o filesystem xfs.
	
		yum install xfsprogs
		mkfs.xfs /dev/sdc
