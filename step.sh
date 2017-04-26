#!/usr/bin/env bash
set -ex

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SONAR_SCANNER_VERSION="3.0.1.733"

if [[ ! -z ${scanner_properties} ]]; then
  if [[ -e sonar-project.properties ]]; then
    echo -e "\e[91mBoth sonar-project.properties file and step properties are provided. Choose only one of them.\e[0m"
    exit 1
  fi
  echo -n "${scanner_properties}" > sonar-project.properties
fi

${THIS_SCRIPT_DIR}/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner

