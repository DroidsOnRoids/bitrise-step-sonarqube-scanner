#!/usr/bin/env bash
set -e

if [[ "${is_debug}" == "true" ]]; then
  set -x
fi

if [[ -n ${scanner_properties} ]]; then
  if [[ -e "${project_settings_path}" ]]; then
    echo -e "\e[34mBoth project configuration file and step properties are provided. Appending properties to the file.\e[0m"
    echo "" >> "${project_settings_path}"
  fi
  echo "${scanner_properties}" >> "${project_settings_path}"
fi

if [[ "$scanner_version" == "latest" ]]; then
  scanner_version=$(curl --silent "https://api.github.com/repos/SonarSource/sonar-scanner-cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  echo "Use latest version: $scanner_version"
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
if [ -n "${JAVA_VERSION_MAJOR}" ]; then
  if [ "${JAVA_VERSION_MAJOR}" -lt "${MINIMUM_JAVA_VERSION_NEEDED}" ]; then
    echo -e "\e[93mSonar Scanner CLI \"${scanner_version}\" requires JRE or JDK version ${MINIMUM_JAVA_VERSION_NEEDED} or newer. Version \"${JAVA_VERSION_MAJOR}\" has been detected, CLI may not work properly.\e[0m"
  fi
else
  echo -e "\e[91mSonar Scanner CLI \"${scanner_version}\" requires JRE or JDK version ${MINIMUM_JAVA_VERSION_NEEDED} or newer. None has been detected, CLI may not work properly.\e[0m"
fi

pushd "$(mktemp -d)"
wget "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${scanner_version}.zip"
unzip "sonar-scanner-cli-${scanner_version}.zip"
TEMP_DIR=$(pwd)
popd

if [[ "${is_debug}" == "true" ]]; then
  debug_flag="-X"
else
  debug_flag=""
fi

"${TEMP_DIR}/sonar-scanner-${scanner_version}/bin/sonar-scanner" ${debug_flag} -Dproject.settings="${project_settings_path}"

