#!/bin/bash

APT_PROGRAMS="nodejs openjdk-11-jdk-headless git curl wget vim zsh nano maven build-essential python3-pip wireguard unzip tar ghc"

TERRAFORM_VERSION="1.0.8"
TERRAGRUNT_VERSION="v0.27.1"
AWS_VAULT_VERSION="6.3.1"
K9S_VERSION="0.24.15"

function install_programs() {
  sudo apt-get update
  sudo apt-get install -y $APT_PROGRAMS
}

function install_aws_vault() {
  wget -q --show-progress "https://raw.githubusercontent.com/Marcel2603/UsefullScripts/master/install_aws_vault.sh" -O install_aws_vault.sh
  bash install_aws_vault.sh $AWS_VAULT_VERSION
}

function install_dhall() {
  path=$PWD
  create_tmp_dir dhall
  DHALL='https://github.com/dhall-lang/dhall-haskell/releases/download/1.40.1/dhall-1.40.1-x86_64-linux.tar.bz2'
  YAML='https://github.com/dhall-lang/dhall-haskell/releases/download/1.40.1/dhall-yaml-1.2.8-x86_64-linux.tar.bz2'
  LSP='https://github.com/dhall-lang/dhall-haskell/releases/download/1.40.1/dhall-lsp-server-1.0.16-x86_64-linux.tar.bz2'
  wget -q --show-progress -O "dhall.tar.bz2" $DHALL
  wget -q --show-progress -O "yaml.tar.bz2" $YAML
  wget -q --show-progress -O "lsp.tar.bz2" $LSP
  tar -xvf "dhall.tar.bz2"
  tar -xvf "yaml.tar.bz2"
  tar -xvf "lsp.tar.bz2"
  cd bin
  move_and_link_file dhall dhall
  move_and_link_file dhall dhall-to-yaml-ng
  move_and_link_file dhall yaml-to-dhall
  move_and_link_file dhall dhall-lsp-server

  remove_tmp_dir dhall $path
}

function install_minikube() {
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
  chmod +x minikube
  move_and_link_file minikube minikube
}

function install_k9s() {
  wget -q --show-progress "https://raw.githubusercontent.com/Marcel2603/UsefullScripts/master/install_k9s.sh" -O install_k9s.sh
  bash install_k9s.sh $K9S_VERSION
}

function install_docker() {
  sudo apt-get update
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
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  set +e
  install_docker_composek
  sudo groupadd docker
  sudo gpasswd -a $USER docker
  set -e
}

function install_docker_compose() {
  curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64" -o docker-compose
  chmod +x docker-compose
  sudo mv docker-compose /usr/local/bin/docker-compose
}

function install_aws_stuff() {
  # create tempFolder
  TEMPDIR="aws-stuff"
  create_temp_dir $TEMPDIR
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
  sudo dpkg -i session-manager-plugin.deb
  echo "Aws installed $(aws --version)"

  install_aws_vault
  delete_temp_dir $TEMPDIR
}

function install_kubectl_and_helm() {
  TEMPDIR="kubectl"
  create_temp_dir $TEMPDIR
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  wget -q --show-progress https://github.com/roboll/helmfile/releases/download/v0.137.0/helmfile_linux_amd64 -O helmfile
  chmod +x helmfile
  sudo mv helmfile /usr/local/bin/helmfile
  helmfile --version
  helm plugin install https://github.com/databus23/helm-diff
  helm plugin install https://github.com/jkroepke/helm-secrets --version v3.8.2
  wget -q --show-progress https://github.com/mozilla/sops/releases/download/v3.7.1/sops_3.7.1_amd64.deb -O sops
  sudo dpkg -i sops
  echo "install dhall"
  delete_temp_dir $TEMPDIR
  install_dhall
}

function install_pygrid() {
  sudo apt-get install -y git python3-gi python3-xlib
  curl -L "https://raw.githubusercontent.com/pkkid/pygrid/master/pygrid.py" -o pygrid
  chmod +x pygrid
  move_and_link_file pygrid pygrid
  autostart=$(
    cat <<EndOfMessage
[Desktop Entry]
Name=pygrid
Exec=/usr/bin/python3 $HOME/.local/bin/pygrid
Type=Application
EndOfMessage
  )
  mkdir -p '$HOME/.config/autostart'
  echo "$autostart" >$HOME/.config/autostart/pygrid.desktop
}

function install_terraform() {
  # create tempFolder
  TEMPDIR="terraform"
  create_temp_dir $TEMPDIR
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  sudo mv ./terraform /usr/local/bin/
  sudo chmod +x /usr/local/bin/terraform
  wget -q --show-progress https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O terragrunt
  sudo mv terragrunt /usr/local/bin/
  sudo chmod +x /usr/local/bin/terragrunt
  echo "Terraform $(terraform --version) and Terragrunt $(terragrunt --version) installed!"
  delete_temp_dir $TEMPDIR
}

function install_tool_box() {
  TEMPDIR="/tmp/jetbrains-toolbox"
  if [[ -d $TEMPDIR ]]; then echo "$TEMPDIR exists, cleaning it" && rm -rf * "${TEMPDIR:?}/*"; else echo "creating TEMPDIR: $TEMPDIR" && mkdir --parents $TEMPDIR; fi
  cd $TEMPDIR || exit 3
  wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.21.9712.tar.gz" -O toolbox.tar.gz
  ls -la
  cd $OLDPWD
  rm -rf TEMPDIR
}

function install_antibody() {
    curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
}

function create_temp_dir() {
  TEMPDIR="/tmp/$1"
  if [[ -d $TEMPDIR ]]; then echo "$TEMPDIR exists, cleaning it" && rm -rf * "${TEMPDIR:?}/*"; else echo "creating TEMPDIR: $TEMPDIR" && mkdir --parents $TEMPDIR; fi
  cd $TEMPDIR || exit 3
}

function delete_temp_dir() {
  cd $OLDPWD || exit 3
  rm -rf "/tmp/$1"
}

function create_tmp_dir() {
  temp_dir="/tmp/$1"
  mkdir --parent $temp_dir
  cd $temp_dir
}

function remove_tmp_dir() {
  temp_dir="/tmp/$1"
  cd $2
  rm -rf $temp_dir
}

function move_and_link_file() {
  FOLDER=$1
  FILE=$2
  OPT_DIR="$HOME/.local/opt/$FOLDER"
  BIN_DIR="$HOME/.local/bin"
  echo "TEST"
  mkdir --parent "$OPT_DIR"
  mkdir --parent "$BIN_DIR"
  mv -v $FILE "$OPT_DIR/"
  ln -sfv $OPT_DIR/$FILE $BIN_DIR
}

function main() {
  set -e
  install_programs
  install_aws_stuff
  install_kubectl_and_helm
  install_terraform
  install_docker
}

"$@"