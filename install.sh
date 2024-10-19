#!/bin/bash

# Atualizando pacotes e instalando dependências
echo "Atualizando pacotes e instalando dependências..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install curl apt-transport-https ca-certificates software-properties-common -y

# Instalando o Docker
echo "Instalando Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Verificando se o Docker foi instalado
docker --version
if [ $? -eq 0 ]; then
  echo "Docker instalado com sucesso!"
else
  echo "Falha na instalação do Docker."
  exit 1
fi

# Instalando o Docker Compose
echo "Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificando se o Docker Compose foi instalado
docker-compose --version
if [ $? -eq 0 ]; then
  echo "Docker Compose instalado com sucesso!"
else
  echo "Falha na instalação do Docker Compose."
  exit 1
fi

# Criando um diretório para o projeto
echo "Criando diretório para o projeto Whaticket..."
mkdir -p ~/whaticket && cd ~/whaticket

# Criando o arquivo docker-compose.yml para Whaticket
echo "Gerando docker-compose.yml..."
cat <<EOL > docker-compose.yml
version: "3.7"
services:
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: whaticket
      MYSQL_USER: whaticket
      MYSQL_PASSWORD: password
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

  whaticket-backend:
    image: garantesoftware/whaticket:latest
    environment:
      DATABASE_URL: mysql://whaticket:password@db:3306/whaticket
    ports:
      - "8080:8080"
    depends_on:
      - db

  whaticket-frontend:
    image: garantesoftware/whaticket-frontend:latest
    environment:
      API_URL: api.digitalzapstore.online
    ports:
      - "3000:3000"
    depends_on:
      - whaticket-backend

volumes:
  db_data:
EOL

# Iniciando o Whaticket
echo "Iniciando os containers do Whaticket..."
sudo docker-compose up -d

# Instalando o Portainer
echo "Instalando Portainer..."
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Exibindo mensagem de sucesso
echo "Instalação concluída. Whaticket está rodando nas portas 8080 e 3000. O Portainer está disponível na porta 9000."
