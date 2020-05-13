#! /bin/bash

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
 
wget https://github.com/relipmoc/skewer/archive/0.2.2.tar.gz
tar -xvf 0.2.2.tar.gz
cd skewer-0.2.2
make
sudo mv skewer /usr/local/bin
skewer
 
cd ~
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
unzip fastqc_v0.11.5.zip
sudo cp -rv FastQC /opt
sudo chmod ugo+x /opt/FastQC/fastqc
sudo ln -s /opt/FastQC/fastqc /usr/local/bin/fastqc
fastqc --version
 
cd ~
wget https://github.com/BenLangmead/bowtie2/releases/download/v2.3.2/bowtie2-2.3.2-legacy-linux-x86_64.zip
unzip bowtie2-2.3.2-legacy-linux-x86_64.zip
sudo cp -rv bowtie2-2.3.2-legacy /opt/bowtie2
sudo ln -s /opt/bowtie2/bowtie* /usr/local/bin
bowtie2 --version
bowtie2-build --version
 
cd ~
wget https://github.com/ablab/spades/releases/download/v3.11.1/SPAdes-3.11.1-Linux.tar.gz
tar -xvf SPAdes-3.11.1-Linux.tar.gz
sudo cp -rv SPAdes-3.11.1-Linux /opt/spades
sudo ln -s /opt/spades/bin/spades.py /usr/local/bin/spades.py
spades.py --version
 
cd ~
wget http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz
tar -xvf hmmer-3.1b2-linux-intel-x86_64.tar.gz
sudo cp -rv hmmer-3.1b2-linux-intel-x86_64 /opt/hmmer
sudo ln -s /opt/hmmer/binaries/* /usr/local/bin
cd ~
hmmscan -h
hmmpress -h
 
cd ~
sudo apt-get install gnupg -y
wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/3.6 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update
sudo apt-get install mongodb-org -y
sudo mkdir -p /data/db
sudo systemctl start mongod
sudo systemctl status mongod

# Install Virtool

VIRTOOL_USER_NAME=virtool
VIRTOOL_HOME_DIR=/home/$VIRTOOL_USER_NAME
VIRTOOL_VERSION=3.9.8
VIRTOOL_RELEASE_FILENAME=virtool.tar.gz
VIRTOOL_DATA_PATH=data
VIRTOOL_WATCH_PATH=watch

sudo adduser --disabled-password --disabled-login --home $VIRTOOL_HOME_DIR  --shell /bin/nologin --gecos $VIRTOOL_USER_NAME,$VIRTOOL_USER_NAME $VIRTOOL_USER_NAME
cd $VIRTOOL_HOME_DIR
wget https://github.com/virtool/virtool/releases/download/v$VIRTOOL_VERSION/$VIRTOOL_RELEASE_FILENAME
tar -xvf $VIRTOOL_RELEASE_FILENAME
rm $VIRTOOL_RELEASE_FILENAME
sudo chown -R $VIRTOOL_USER_NAME:$VIRTOOL_USER_NAME .

cat >> /etc/systemd/system/virtoold.service <<EOL
[Unit]
Description=Virtool v$VIRTOOL_VERSION An application server for NGS-based virus diagnostics.
Documentation=https://www.virtool.ca/docs

[Service]
Type=simple
User=$VIRTOOL_USER_NAME
WorkingDirectory=$VIRTOOL_HOME_DIR/virtool
ExecStart=$VIRTOOL_HOME_DIR/virtool/run --host "localhost" --port 9950 --data-path="$VIRTOOL_DATA_PATH" --watch-path="$VIRTOOL_WATCH_PATH" --db="mongodb://mongo:27017" --db-name="$VIRTOOL_USER_NAME" --proc 1 --mem 2 --lg-proc 1 --lg-mem 1 --sm-proc 1 --sm-mem 1 --dev

[Install]
WantedBy=network.target mnt-array0.mount
EOL

sudo systemctl enable virtoold
sudo systemctl start virtoold
sudo systemctl status virtoold