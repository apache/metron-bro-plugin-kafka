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
RAN_BRO_CONTAINER=false

SKIP_REBUILD_BRO=false

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
SCRIPT_DIR="${ROOT_DIR}"/scripts
CONTAINER_DIR="${ROOT_DIR}"/containers/bro-localbuild-container
LOG_PATH="${ROOT_DIR}"/logs
DATA_PATH="${ROOT_DIR}"/data
OUTPUT_PATH="${ROOT_DIR}"/kafka_output

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --skip-docker-build             Skip build of bro docker machine."
  echo "    --data-path                     [OPTIONAL] The pcap data path, defaults to ./data"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

function shutdown {

  if [[ "$RAN_BRO_CONTAINER" = true ]]; then
    "${SCRIPT_DIR}"/stop_container.sh --container-name=bro
  fi

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

# handle command line options
for i in "$@"; do
  case $i in

  #
  # FORCE_DOCKER_BUILD
  #
  #   --skip-docker-build
  #
    --skip-docker-build)
      SKIP_REBUILD_BRO=true
      shift # past argument
    ;;

  #
  # DATA_PATH
  #
  #
  #
    --data-path=*)
      DATA_PATH="${i#*=}"
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
  esac
done

EXTRA_ARGS="$@"

echo "Running build_container with "
echo "SKIP_REBUILD_BRO = $SKIP_REBUILD_BRO"
echo "==================================================="

# create the network
bash "${SCRIPT_DIR}"/create_docker_network.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc}
else
  CREATED_NETWORK_FLAG=true
fi



# run the zookeeper container
bash "${SCRIPT_DIR}"/docker_run_zookeeper_container.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc}
else
  RAN_ZK_CONTAINER=true
fi

# wait for zookeeper to be up
bash "${SCRIPT_DIR}"/docker_run_wait_for_zookeeper.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc}
fi

# run the kafka container
bash "${SCRIPT_DIR}"/docker_run_kafka_container.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc}
else
  RAN_KAFKA_CONTAINER=true
fi

# wait for kafka to be up
bash "${SCRIPT_DIR}"/docker_run_wait_for_kafka.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc}
fi

# create the bro topic
bash "${SCRIPT_DIR}"/docker_run_create_bro_topic_in_kafka.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc}
fi

#build the bro container
if [[ "$SKIP_REBUILD_BRO" = false ]]; then
  bash "${SCRIPT_DIR}"/build_container.sh \
 --container-directory="${CONTAINER_DIR}" \
 --container-name=metron-bro-docker-container:latest

  rc=$?; if [[ ${rc} != 0 ]]; then
    shutdown
    exit ${rc}
  fi
fi

# download the pcaps
bash "${SCRIPT_DIR}"/download_sample_pcaps.sh --data-path="${DATA_PATH}"

#run the bro container
#and optionally the passed script _IN_ the container
bash "${SCRIPT_DIR}"/docker_run_bro_container.sh \
 --log-path="${LOG_PATH}" \
 --data-path="${DATA_PATH}" \
 $EXTRA_ARGS


rc=$?; if [[ ${rc} != 0 ]]; then
  shutdown
  exit ${rc}
else
  RAN_BRO_CONTAINER=true
fi

# build the bro plugin
bash "${SCRIPT_DIR}"/docker_execute_build_bro_plugin.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR> FAILED TO BUILD PLUGIN.  CHECK LOGS  ${rc}"
  shutdown
  exit ${rc}
fi

# configure it the bro plugin
bash "${SCRIPT_DIR}"/docker_execute_configure_bro_plugin.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR> FAILED TO CONFIGURE PLUGIN.  CHECK LOGS  ${rc}"
  shutdown
  exit ${rc}
fi

bash "${SCRIPT_DIR}"/docker_execute_process_data_dir.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR> FAILED TO PROCESS ${DATA_PATH} DATA.  CHECK LOGS  ${rc}, please run the finish_end_to_end.sh when you are done."
  exit ${rc}
fi

DATE=$(date)
LOG_DATE=${DATE// /_}
KAFKA_OUTPUT_FILE="${OUTPUT_PATH}/kafka-output-${LOG_DATE}.log"
bash "${SCRIPT_DIR}"/docker_run_consume_bro_kafka.sh | "${ROOT_DIR}"/remove_timeout_message.sh | tee "${KAFKA_OUTPUT_FILE}"

echo "Run complete"
echo "The kafka output can be found at ${KAFKA_OUTPUT_FILE}"
echo "You may now work with the containers if you will.  You need to call finish_end_to_end.sh when you are done"

