1. Execute o comando hostname em um container usando a imagem alpine. Certifique-se que o container será removido após a execução.

	docker container run alpine sh -c "hostname" && docker container prune
	

2. Crie um container com a imagem nginx (versão 1.22), expondo a porta 80 do container para a porta 8080 do host.

	docker container run -d -p 8080:80 nginx:1.22
	

3. Faça o mesmo que a questão anterior (2), mas utilizando a porta 90 no container. O arquivo de configuração do nginx deve existir no host e ser read-only no container.

	3.1 default.conf:

		server {
		    listen       90;
		    listen  [::]:90;
		    server_name  localhost;

		    location / {
			root   /usr/share/nginx/html;
			index  index.html index.htm;
		    }

		    error_page  404              /404.html;
		    
		    error_page   500 502 503 504  /50x.html;
		    
		    location = /50x.html {
			root   /usr/share/nginx/html;
		    }
		  
		    location ~ \.php$ {
			root           html;
			fastcgi_pass   127.0.0.1:9000;
			fastcgi_index  index.php;
			fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
			include        fastcgi_params;
		    }
		}

	3.2 Comando:

		docker container run -d -p 8080:90 --mount type=bind,src=$(pwd)/default.conf,dst=/etc/nginx/conf.d/default.conf,ro nginx:1.22
		

4. Construa uma imagem para executar o programa abaixo:

	4.1 python.py:

		def main():
		   print('Hello World in Python!')

		if __name__ == '__main__':
		  main()

	4.2 Dockerfile:

		FROM python:3
		WORKDIR /usr/src/app
		COPY python.py ./
		CMD ["python", "./python.py"]

	4.3 Comando:

		docker image build -t hwip:0.0.1 .
		docker run hwip:0.0.1
		
	
5. Execute um container da imagem nginx com limite de memória 128MB e 1/2 CPU.

	docker container run -d -p 8080:80 --cpus="0.5" -m 128m nginx
	
	
6. Qual o comando usado para limpar recursos como imagens, containers parados, cache de build e networks não utilizadas?

	docker system prune -a
	
	
7. Como você faria para extrair os comandos Dockerfile de uma imagem?

	docker image history [nome_da_imagem]
