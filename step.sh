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


# Identify minimum Java version required based on Sonarqube scanner used
MINIMUM_JAVA_VERSION_NEEDED="8"
if [[ $(echo "$scanner_version" | cut -d'.' -f1) -ge "4" ]]; then
  if [[ $(echo "$scanner_version" | cut -d'.' -f2) -gt "0" ]]; then
    MINIMUM_JAVA_VERSION_NEEDED="11"
  fi
fi


# Check current Java version against the minimum one required
JAVA_VERSION_MAJOR=$(javac -version 2>&1 | cut -d' ' -f2 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
if [ ! -z "${JAVA_VERSION_MAJOR}" ]; then
  if [ "${JAVA_VERSION_MAJOR}" -le "${MINIMUM_JAVA_VERSION_NEEDED}" ]; then
    echo -e "\e[93mSonar Scanner CLI \"${scanner_version}\" requires JRE or JDK version ${MINIMUM_JAVA_VERSION_NEEDED} or newer. Version \"${JAVA_VERSION_MAJOR}\" has been detected, CLI may not work properly.\e[0m"
  fi
else
  echo -e "\e[91mSonar Scanner CLI \"${scanner_version}\" requires JRE or JDK version ${MINIMUM_JAVA_VERSION_NEEDED} or newer. None has been detected, CLI may not work properly.\e[0m"
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

