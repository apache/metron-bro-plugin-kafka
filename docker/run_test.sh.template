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

CREATED_NETWORK_FLAG=false
RAN_ZK_CONTAINER=false
RAN_KAFKA_CONTAINER=false
CREATED_BRO_CONTAINER=false
RAN_BRO_CONTAINER=false

SCRIPT_DIR=./scripts
CONTAINER_DIR=./containers/bro-localbuild-container
CONTAINER_NAME=
LOG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && cd logs && pwd )"

function help {
 echo " "
 echo "    -h/--help                       Usage information."
 echo " "
 echo " "
}

function shutdown {
  if [[ "$RAN_KAFKA_CONTAINER" = true ]]; then
    "${SCRIPT_DIR}"/stop_container.sh --container-name=kafka
  fi

  if [[ "$RAN_ZK_CONTAINER" = true ]]; then
    "${SCRIPT_DIR}"/stop_container.sh --container-name=zookeeper
  fi

  if [[ "$CREATED_NETWORK_FLAG" = true ]]; then
    "${SCRIPT_DIR}"/destroy_docker_network.sh --network-name=bro-network
  fi
}

# create the network
"${SCRIPT_DIR}"/create_docker_network.sh --network-name=bro-network
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc};
else
  CREATED_NETWORK_FLAG=true
fi



# run the zookeeper container
"${SCRIPT_DIR}"/run_zookeeper_container.sh --network-name=bro-network
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc};
else
  RAN_ZK_CONTAINER=true
fi

# run the kafka container
"${SCRIPT_DIR}"/run_kafka_container.sh --network-name=bro-network
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc};
else
  RAN_KAFKA_CONTAINER=true
fi

#build the bro container
"${SCRIPT_DIR}"/build_container.sh \
  --container-directory="${CONTAINER_DIR}" \
  --container-name=bro-docker-container:latest

rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc};
else
  CREATED_BRO_CONTAINER=true
fi


#run the bro container
#and optionally the passed script _IN_ the container
"${SCRIPT_DIR}"/run_bro_container.sh --container-path="${CONTAINER_DIR}" \
  --container-name=bro-docker-container:latest \
  --network-name=bro-network \
  --log-path="${LOG_PATH}"

rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc};
else
  RAN_BRO_CONTAINER=true
fi



#optionally run the kafka consumer script


#shutdown
shutdown
