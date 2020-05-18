#!/usr/bin/env bash

#
#  Licensed to the Apache Software Foundation (ASF) under one or more
#  contributor license agreements.  See the NOTICE file distributed with
#  this work for additional information regarding copyright ownership.
#  The ASF licenses this file to You under the Apache License, Version 2.0
#  (the "License"); you may not use this file except in compliance with
#  the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

shopt -s nocasematch
shopt -s globstar nullglob
shopt -s nocasematch
set -u # nounset
# set -e (errexit) omitted to enable printfiles function call
set -E # errtrap
set -o pipefail

#
# Runs zkg to build and install the plugin
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --plugin-version                [REQUIRED] The plugin version."
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

function printfiles {
  echo "==================================================="
  echo "ERR"
  cat /root/.zkg/testing/code/clones/code/zkg.test_command.stderr
  echo "==================================================="
  echo "OUT"
  cat /root/.zkg/testing/code/clones/code/zkg.test_command.stdout
  echo "==================================================="
  echo ""
  echo "==================================================="
  echo ""
}

PLUGIN_VERSION=

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # PLUGIN_VERSION
  #
  #   --plugin-version
  #
    --plugin-version=*)
      PLUGIN_VERSION="${i#*=}"
      shift # past argument=value
    ;;

  #
  # -h/--help
  #
    -h | --help)
      help
      exit 0
      shift # past argument with no value
    ;;

  #
  # Unknown option
  #
    *)
      UNKNOWN_OPTION="${i#*=}"
      echo "Error: unknown option: $UNKNOWN_OPTION"
      help
    ;;
  esac
done

if [[ -z "${PLUGIN_VERSION}" ]]; then
  echo "PLUGIN_VERSION must be passed"
  exit 1
fi

echo "PLUGIN_VERSION = ${PLUGIN_VERSION}"

cd /root || exit 1

echo "==================================================="

zkg -vvv test code --version "${PLUGIN_VERSION}"
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR running zkg test ${rc}"
  printfiles
  exit ${rc}
fi

zkg -vvv install code --skiptests --version "${PLUGIN_VERSION}" --force
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR running zkg install ${rc}"
  printfiles
  exit ${rc}
fi

zeek -NN Apache::Kafka

echo "==================================================="
echo ""

