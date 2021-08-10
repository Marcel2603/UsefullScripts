#!/usr/bin/bash
set -e

GRADLE_VERSION="${1:-7.1.1}"
GRADLE_RELEASE="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
TEMP_DIR="gradle_temp"
GRADLE_OPT_DIR="${HOME}/.local/opt/gradle"
BIN_DIR="${HOME}/.local/bin"

mkdir -p "$GRADLE_OPT_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$TEMP_DIR"

echo "Download Gradle with Version $GRADLE_VERSION, you can modify the Version, by giving me the complete Version as Parameter. "
wget "$GRADLE_RELEASE" -O "${TEMP_DIR}/gradle.zip" -q --show-progress

echo "Unzip gradle to $GRADLE_OPT_DIR"
unzip -q -o -d "${GRADLE_OPT_DIR}" "${TEMP_DIR}/gradle.zip"

ln -f -s "${GRADLE_OPT_DIR}/gradle-${GRADLE_VERSION}/bin/gradle" "${BIN_DIR}/gradle"

rm -rf "$TEMP_DIR"

if [[ "$PATH" == "*$BIN_DIR*" ]]; 
then
  echo -e "Im finished!You have gradle \n$(gradle -v)"
else 
  echo -e "Pls include $BIN_DIR to your PATH!!\nJust run export PATH=${BIN_DIR}:\$PATH \n" 
  export PATH="${BIN_DIR}:${PATH}"
  echo -e "Just to prove that you have gradle now, IF YOU SET THE PATH CORRECTLY!!!!!! \n$(gradle -v)" 
fi
