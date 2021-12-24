#!/bin/bash
# Instalação NovoSga 2.0
# Frederico Mazzo, 2021
# fredericosmazzo@gmail.com

clear

echo -e "\e[38;5;14m|------------------------------------------- \e[0m"
echo -e "\e[38;5;14m| FredoMazzo NovoSGA 2.0 Instalação Ubuntu 18.0.4 \e[0m"
echo -e "\e[38;5;14m|------------------------------------------- \e[0m"
echo -e "\e[38;5;14m| \e[0m"
echo -e "\e[38;5;14m| * Git \  \e[0m"
echo -e "\e[38;5;14m| * Unzip \  \e[0m"
echo -e "\e[38;5;14m| * Aapache 2 \e[0m"
echo -e "\e[38;5;14m| * PHP 7.4 \  \e[0m"
echo -e "\e[38;5;14m| * MariaDB 10 \  \e[0m"
echo -e "\e[38;5;14m| * Composer \  \e[0m"
echo -e "\e[38;5;14m| * Projeto NovoSGA \  \e[0m"
echo -e "\e[38;5;14m| * Configurações \  \e[0m"
echo -e "\e[38;5;14m| * Painel de Senhas! \  \e[0m"
echo -e "\e[38;5;14m| * para Ubuntu 18.0.4 \e[0m"
echo -e "\e[38;5;14m| \e[0m"
echo -e "\e[38;5;14m| fredericosmazzo@gmail.com 12/2021  \e[0m"
echo -e "\e[38;5;14m|------------------------------------------- \e[0m"
echo -e " "
echo -e "\e[38;5;220m ? Pressione qualquer tecla para continuar... \e[0m"
read -p " " -n1 -s

# Git
clear
echo -e ""
echo -e "\e[38;5;14m| Git \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo apt install -y git

# Unzip
clear
echo -e ""
echo -e "\e[38;5;14m| Unzip \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo apt install -y unzip

# Apache 2
clear
echo -e ""
echo -e "\e[38;5;14m| Apache 2 \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo apt install -y apache2 apache2-utils
sudo systemctl enable apache2
sudo a2enmod rewrite env
sudo systemctl restart apache2
sudo chmod -R 777 /etc/apache2/
sudo systemctl restart apache2

# PHP
clear
echo -e ""
echo -e "\e[38;5;14m| PHP 7.4 \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo apt-add-repository ppa:ondrej/php
sudo apt update
sudo apt install -y php7.4 php7.4-mysql php7.4-curl php7.4-zip php7.4-intl php7.4-xml php7.4-mbstring

# MariaDB
clear
echo -e ""
echo -e "\e[38;5;14m| MariaDB \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo apt -y install mariadb-server
sudo service mysql start
sudo mysql_secure_installation

clear
echo -e ""
echo -e "\e[38;5;14m| Código para usar no MySQL \e[0m"
echo -e "\e[38;5;14m| CREATE DATABASE novosga; \e[0m"
echo -e "\e[38;5;14m| CREATE USER 'novosga'@'%' IDENTIFIED BY 'semas2021'; \e[0m"
echo -e "\e[38;5;14m| GRANT ALL PRIVILEGES ON novosga.* TO 'novosga'@'%' IDENTIFIED BY 'semas2021'; \e[0m"
echo -e "\e[38;5;14m| FLUSH PRIVILEGES;\e[0m"
echo -e "\e[38;5;14m| EXIT;\e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo mysql -u root -p

# Composer
clear
echo -e ""
echo -e "\e[38;5;14m| Instalação do Composer   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo wget https://getcomposer.org/download/1.6.0/composer.phar
sudo chmod +X composer.phar

# Projeto NovoSGA
clear
echo -e ""
echo -e "\e[38;5;14m| Criação do Projeto NovoSGA   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

export LANGUAGE=pt_BR
php composer.phar create-project "novosga/novosga:^2.0" ~/novosga
php composer.phar update -d ~/novosga

# Mover Pasta
clear
echo -e ""
echo -e "\e[38;5;14m| Movendo a Pasta do SGA e dando Permissões   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo mv novosga /var/www/html/
sudo chmod -R 777 /var/www/html/novosga/

# Preparar Ambiente
clear
echo -e ""
echo -e "\e[38;5;14m| Preparar o cache da aplicação para o ambiente de produção   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

cd /var/www/html/novosga
sudo bin/console cache:clear --no-debug --no-warmup --env=prod
sudo bin/console cache:warmup --env=prod

# Alterar Diretório Raiz
clear
echo -e ""
echo -e "\e[38;5;14m| Alterar diretório raiz e habilitar   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

sudo sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

sudo echo '<Directory /var/www/html>
            AllowOverride All
           </Directory>' >> /etc/apache2/sites-available/000-default.conf

# Configurar Dados do .htaccess
clear
echo -e ""
echo -e "\e[38;5;14m| Criar e editar o arquivo .htaccess   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

read -p "Informe o nome de usuário MySQL: " usuario
read -p "Informe a senha do usuário MySQL: " senha
read -p "Informe o nome do Banco MySQL: " banco

echo 'Options -MultiViews
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ index.php [QSA,L]
SetEnv APP_ENV prod
SetEnv LANGUAGE pt_BR
SetEnv DATABASE_URL mysql://'$usuario':'$senha'@localhost:3306/'$banco > /var/www/html/novosga/public/.htaccess

sudo timedatectl set-timezone America/Sao_Paulo
sudo systemctl restart apache2
sudo chmod -R 777 /var/www/html/novosga/
# Instalar o SGA
clear
echo -e ""
echo -e "\e[38;5;14m| Instalaçao do Sistema   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

APP_ENV=prod \
LANGUAGE=pt_BR \
DATABASE_URL="mysql://"$usuario":"$senha"@localhost:3306/"$banco \
bin/console novosga:install

sudo chmod -R 777 /var/www/html/novosga/

# Instalar o Painel
clear
echo -e ""
echo -e "\e[38;5;14m| Instalaçao do Painel de Senhas   \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"

cd /var/www/html/novosga/
wget https://github.com/novosga/panel-app/releases/download/v2.0.1/painel-web-2.0.1.zip
unzip painel-web-2.0.1.zip

echo -e ""
echo -e "\e[38;5;14m| Sistema Instalado com sucesso!   \e[0m"
echo -e "\e[38;5;14m  Acesse o sistema: http://seu_ip/novosga/public ---- \e[0m"
echo -e "\e[38;5;14m  Acesse o Painel: http://seu_ip/novosga/painel-web-2.0.1 ---- \e[0m"
echo -e "\e[38;5;14m------------------------------------------- \e[0m"



