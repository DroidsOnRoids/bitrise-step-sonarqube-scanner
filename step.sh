#!/usr/bin/env bash
set -e

if [[ "${is_debug}" == "true" ]]; then
  set -x
fi


if [[ ! -z ${scanner_properties} ]]; then
  if [[ -e sonar-project.properties ]]; then
    echo -e "\e[34mBoth sonar-project.properties file and step properties are provided. Appending properties to the file.\e[0m"
    echo "" >> sonar-project.properties
  fi
  echo "${scanner_properties}" >> sonar-project.properties
fi

JAVA_VERSION_MAJOR=$(java -version 2>&1 | grep -i version | sed 's/.*version ".*\.\(.*\)\..*"/\1/; 1q')
if [ ! -z "${JAVA_VERSION_MAJOR}" ]; then
  if [ "${JAVA_VERSION_MAJOR}" -lt "8" ]; then
    echo -e "\e[93mSonar Scanner CLI requires JRE or JDK version 8 or newer. Version \"${JAVA_VERSION_MAJOR}\" has been detected, CLI may not work properly.\e[0m"
  fi
else
  echo -e "\e[91mSonar Scanner CLI requires JRE or JDK version 8 or newer. None has been detected, CLI may not work properly.\e[0m"
fi

pushd $(mktemp -d)
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${scanner_version}.zip
unzip sonar-scanner-cli-${scanner_version}.zip
TEMP_DIR=$(pwd)
popd



if [[ "${is_debug}" == "true" ]]; then
  debug_flag="-X"
else
  debug_flag=""
fi

${TEMP_DIR}/sonar-scanner-${scanner_version}/bin/sonar-scanner $debug_flag

