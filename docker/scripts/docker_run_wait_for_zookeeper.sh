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
set -u # nounset

#
# Executes a wait script for zookeeper
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --network-name                  [OPTIONAL] The Docker network name. Default: bro-network"
  echo "    -h/--help                       Usage information."
  echo " "
}
DOCKER_SCRIPTS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && cd  .. > /dev/null && cd in_docker_scripts && pwd)"


NETWORK_NAME=bro-network

# handle command line options
for i in "$@"; do
  case $i in
  #
  # NETWORK_NAME
  #
  #
  #
    --network-name=*)
      NETWORK_NAME="${i#*=}"
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

echo "Running docker_run_wait_for_zookeeper with "
echo "NETWORK_NAME = $NETWORK_NAME"
echo "==================================================="

docker run --rm -i -t -w /root --network "${NETWORK_NAME}" -v "${DOCKER_SCRIPTS_PATH}":/root/scripts centos bash -c "bash /root/scripts/wait_for_zk.sh"

rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi
