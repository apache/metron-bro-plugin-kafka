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
set -e # errexit
set -E # errtrap
set -o pipefail
#
# Stops the containers, and shuts down the NETWORK_NAME
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --container-name                [OPTIONAL] The Docker container name. Default: bro"
  echo "    --network-name                  [OPTIONAL] The Docker network name. Default: bro-network"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

CONTAINER_NAME=bro
NETWORK_NAME=bro-network

# handle command line options
for i in "$@"; do
  case $i in

  #
  # CONTAINER_NAME
  #
  #   --container-name
  #
    --container-name=*)
      CONTAINER_NAME="${i#*=}"
      shift # past argument
    ;;

  #
  # NETWORK_NAME
  #
  #   --network-name
  #
    --network-name=*)
      NETWORK_NAME="${i#*=}"
      shift # past argument
    ;;

  #
  # -h/--help
  #
    -h | --help)
      help
      exit 0
      shift # past argument with no value
    ;;
  esac
done

echo "Running cleanup_containers with "
echo "CONTAINER_NAME = $CONTAINER_NAME"
echo "NETWORK_NAME   = $NETWORK_NAME"
echo "==================================================="

"${SCRIPT_DIR}"/stop_container.sh --container-name="${CONTAINER_NAME}"

"${SCRIPT_DIR}"/stop_container.sh --container-name=kafka

"${SCRIPT_DIR}"/stop_container.sh --container-name=zookeeper

"${SCRIPT_DIR}"/destroy_docker_network.sh --network-name="${NETWORK_NAME}"

