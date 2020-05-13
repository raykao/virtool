#! /bin/bash

VIRTOOL_USER_NAME=virtool
VIRTOOL_HOME_DIR=/home/$VIRTOOL_USER_NAME
VIRTOOL_VERSION=3.9.8
VIRTOOL_RELEASE_FILENAME=virtool.tar.gz
VIRTOOL_DATA_PATH=data
VIRTOOL_WATCH_PATH=watch

SKEWER_VERSION=0.2.2
FASTQC_VERSION=0.11.5
BOWTIE2_VERSION=2.3.2
SPADES_VERSION=3.11.1
HMMER_VERSION=3.1b2

# Values passed in by Terraform or Packer Template
DOMAIN_NAME=${domain_name}
ADMIN_EMAIL_ADDRESS=${admin_email_address}

# Docker
# https://docs.docker.com/engine/install/ubuntu/

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

# Virtool

sudo apt-get update && sudo apt-get install -y build-essential wget unzip default-jre
 
wget https://github.com/relipmoc/skewer/archive/$SKEWER_VERSION.tar.gz
tar -xvf $SKEWER_VERSION.tar.gz
cd skewer-$SKEWER_VERSION
make
sudo mv skewer /usr/local/bin
skewer
 
cd ~
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v$FASTQC_VERSION.zip
unzip fastqc_v$FASTQC_VERSION.zip
sudo cp -rv FastQC /opt
sudo chmod ugo+x /opt/FastQC/fastqc
sudo ln -s /opt/FastQC/fastqc /usr/local/bin/fastqc
fastqc --version
 
cd ~
wget https://github.com/BenLangmead/bowtie2/releases/download/v$BOWTIE2_VERSION/bowtie2-$BOWTIE2_VERSION-legacy-linux-x86_64.zip
unzip bowtie2-$BOWTIE2_VERSION-legacy-linux-x86_64.zip
sudo cp -rv bowtie2-$BOWTIE2_VERSION-legacy /opt/bowtie2
sudo ln -s /opt/bowtie2/bowtie* /usr/local/bin
bowtie2 --version
bowtie2-build --version
 
cd ~
wget https://github.com/ablab/spades/releases/download/v$SPADES_VERSION/SPAdes-$SPADES_VERSION-Linux.tar.gz
tar -xvf SPAdes-$SPADES_VERSION-Linux.tar.gz
sudo cp -rv SPAdes-$SPADES_VERSION-Linux /opt/spades
sudo ln -s /opt/spades/bin/spades.py /usr/local/bin/spades.py
spades.py --version
 
cd ~
wget http://eddylab.org/software/hmmer3/$HMMER_VERSION/hmmer-$HMMER_VERSION-linux-intel-x86_64.tar.gz
tar -xvf hmmer-$HMMER_VERSION-linux-intel-x86_64.tar.gz
sudo cp -rv hmmer-$HMMER_VERSION-linux-intel-x86_64 /opt/hmmer
sudo ln -s /opt/hmmer/binaries/* /usr/local/bin
cd ~
hmmscan -h
hmmpress -h

# Install Virtool
sudo adduser --disabled-password --disabled-login --home $VIRTOOL_HOME_DIR  --shell /bin/nologin --gecos $VIRTOOL_USER_NAME,$VIRTOOL_USER_NAME $VIRTOOL_USER_NAME
cd $VIRTOOL_HOME_DIR
wget https://github.com/virtool/virtool/releases/download/v$VIRTOOL_VERSION/$VIRTOOL_RELEASE_FILENAME
tar -xvf $VIRTOOL_RELEASE_FILENAME
rm $VIRTOOL_RELEASE_FILENAME
sudo chown -R $VIRTOOL_USER_NAME:$VIRTOOL_USER_NAME .

cat > /etc/systemd/system/virtoold.service <<EOL
[Unit]
Description=Virtool v$VIRTOOL_VERSION An application server for NGS-based virus diagnostics.
Documentation=https://www.virtool.ca/docs

[Service]
Type=simple
User=$VIRTOOL_USER_NAME
WorkingDirectory=$VIRTOOL_HOME_DIR/virtool
ExecStart=$VIRTOOL_HOME_DIR/virtool/run --host "localhost" --port 9950 --data-path="$VIRTOOL_DATA_PATH" --watch-path="$VIRTOOL_WATCH_PATH" --db-name="$VIRTOOL_USER_NAME" --proc 1 --mem 2 --lg-proc 1 --lg-mem 1 --sm-proc 1 --sm-mem 1 --dev

[Install]
WantedBy=network.target mnt-array0.mount
EOL

sudo systemctl daemon-reload
sudo systemctl enable virtoold
sudo systemctl start virtoold

# Nginx
sudo apt-get -y install nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Certbot https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx.html
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update

sudo apt-get install -y certbot python3-certbot-nginx

sudo certbot --nginx -n --agree-tos -d $DOMAIN_NAME -m $ADMIN_EMAIL_ADDRESS 

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

cat > /etc/nginx/sites-available/default <<EOL
upstream virtool {
  server 127.0.0.1:9950;
}

server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                try_files $uri $uri/ =404;
        }
}


server {

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;
    server_name $DOMAIN_NAME; # managed by Certbot


        location / {
                proxy_pass http://virtool;
        }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if (\$host = $DOMAIN_NAME) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen 80 ;
        listen [::]:80 ;
    server_name $DOMAIN_NAME;
    return 404; # managed by Certbot


}
EOL

sudo systemctl daemon-reload
sudo systemctl restart nginx
