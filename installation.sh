#!/bin/bash

CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
VS_CODE="https://az764295.vo.msecnd.net/stable/7f6ab5485bbc008386c4386d08766667e155244e/code_1.60.2-1632313585_amd64.deb"
ATOM='https://atom.io/download/deb'

APT_PROGRAMS="git curl openjdk-11-jdk zsh maven python3-pip ghc"

DEBS=("$CHROME $VS_CODE $ATOM")

function install_debs() {
  temp_file="deb_file.deb"
  for deb in $DEBS:; do
    wget -O "$temp_file" "$deb"
    sudo dpkg -i $temp_file
    rm $temp_file
  done
  install_atom_packages
}

function install_apt_programs() {
  sudo apt-get update -y
  sudo apt-get install -y $APT_PROGRAMS
}

function install_atom_packages() {
  apm install atom-ide-ui
}

function install_dhall() {
  path=$PWD
  create_tmp_dir dhall
  DHALL='https://github.com/dhall-lang/dhall-haskell/releases/download/1.40.1/dhall-1.40.1-x86_64-linux.tar.bz2'
  YAML='https://github.com/dhall-lang/dhall-haskell/releases/download/1.40.1/dhall-yaml-1.2.8-x86_64-linux.tar.bz2'
  LSP='https://github.com/dhall-lang/dhall-haskell/releases/download/1.40.1/dhall-lsp-server-1.0.16-x86_64-linux.tar.bz2'
  wget -O "dhall.tar.bz2" $DHALL
  wget -O "yaml.tar.bz2" $YAML
  wget -O "lsp.tar.bz2" $LSP
  tar -xf "dhall.tar.bz2"
  tar -xf "yaml.tar.bz2"
  tar -xf "lsp.tar.bz2"
  cd bin
  move_and_link_file dhall dhall
  move_and_link_file dhall dhall-to-yaml-ng
  move_and_link_file dhall yaml-to-dhall
  move_and_link_file dhall dhall-lsp-server

  remove_tmp_dir dhall $path
}

function install_minikube() {
  wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O minikube
  chmod +x minikube
  move_and_link_file minikube minikube
}

function install_kind() {
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
  chmod +x ./kind 
  move_and_link_file kind kind
}

function install_helm() {
  path=$PWD
  create_tmp_dir helm
  curl -Lo helm.tar.gz https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz
  tar -xvf helm.tar.gz
  cd linux-amd64 
  move_and_link_file helm helm
  remove_tmp_dir helm $path
}

function install_docker() {
  sudo apt update
  sudo apt install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io
  sudo groupadd docker
  sudo usermod -aG docker $USER
}

function install_docker_compose() {
  curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64" -o docker-compose
  chmod +x docker-compose
  sudo mv docker-compose /usr/local/bin/docker-compose
}

function install_android_studio() {
  URL='https://r5---sn-4g5e6nsd.gvt1.com/edgedl/android/studio/ide-zips/2020.3.1.24/android-studio-2020.3.1.24-linux.tar.gz?cms_redirect=yes&mh=3q&mip=2003:fd:6709:be2:d93:5c42:e23d:3615&mm=28&mn=sn-4g5e6nsd&ms=nvh&mt=1633167774&mv=u&mvi=5&pl=36&rmhost=r2---sn-4g5e6nsd.gvt1.com&shardbypass=yes&smhost=r2---sn-4g5e6nsk.gvt1.com'
  ARCHIVE="android-studio.tar.gz"
  path=$PWD
  sudo apt-get install -y adb
  OPT_DIR="$HOME/.local/opt/android-studio"
  create_tmp_dir android
  curl -L "$URL" -o $ARCHIVE
  tar -xvf $ARCHIVE
  mkdir -p $OPT_DIR
  mv -fv android-studio/* $OPT_DIR
  cd $OPT_DIR/bin
  ./studio.sh
  remove_tmp_dir android $path
}

function install_k8s() {
  path=$PWD
  create_tmp_dir k8s
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  move_and_link_file kubectl kubectl
  source <(kubectl completion bash)
  curl -LO "https://raw.githubusercontent.com/Marcel2603/UsefullScripts/master/install_k9s.sh"
  chmod +x install_k9s.sh
  ./install_k9s.sh 0.24.15
  remove_tmp_dir k8s $path
  install_minikube
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
  echo "$autostart" > $HOME/.config/autostart/pygrid.desktop
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
  mkdir --parent "$OPT_DIR"
  mkdir --parent "$BIN_DIR"
  mv $FILE "$OPT_DIR/"
  ln -sf $OPT_DIR/$FILE $BIN_DIR
}

function main() {
  install_apt_programs
  install_debs
  install_atom_packages
  install_dhall
  install_minikube
}

"$@"
