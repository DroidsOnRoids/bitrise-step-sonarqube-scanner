#!/usr/bin/env bash
set -ex

if [[ ! -z ${scanner_properties} ]]; then
  if [[ -e sonar-project.properties ]]; then
    echo -e "\e[91mBoth sonar-project.properties file and step properties are provided. Choose only one of them.\e[0m"
    exit 1
  fi
  echo -n "${scanner_properties}" > sonar-project.properties
fi

JAVA_VERSION_MAJOR=$(java -version 2>&1 | grep -i version | sed 's/.*version ".*\.\(.*\)\..*"/\1/; 1q')
if [ "${JAVA_VERSION_MAJOR}" -lt "8" ]; then
  echo -e "\e[91mSonar Scanner CLI requires JRE or JDK version 8 or newer. Version \"${JAVA_VERSION_MAJOR}\" has been detected, CLI may not work properly.\e[0m"
fi

pushd $(mktemp -d)
wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${scanner_version}.zip
unzip sonar-scanner-cli-${scanner_version}.zip
TEMP_DIR=$(pwd)
popd

${TEMP_DIR}/sonar-scanner-${scanner_version}/bin/sonar-scanner

