#!/usr/bin/env bash
set -ex

if [[ ! -z ${scanner_properties} ]]; then
  if [[ -e sonar-project.properties ]]; then
    echo -e "\e[91mBoth sonar-project.properties file and step properties are provided. Choose only one of them.\e[0m"
    exit 1
  fi
  echo -n "${scanner_properties}" > sonar-project.properties
fi

pushd $(mktemp -d)
wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${scanner_version}.zip
unzip sonar-scanner-cli-${scanner_version}.zip
TEMP_DIR=$(pwd)
popd

${TEMP_DIR}/sonar-scanner-${scanner_version}/bin/sonar-scanner

