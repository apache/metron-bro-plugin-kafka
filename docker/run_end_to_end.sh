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

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --skip-docker-build             [OPTIONAL] Skip build of bro docker machine."
  echo "    --data-path                     [OPTIONAL] The pcap data path. Default: ./data"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

SKIP_REBUILD_BRO=false

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
SCRIPT_DIR="${ROOT_DIR}"/scripts
CONTAINER_DIR="${ROOT_DIR}"/containers/bro-localbuild-container
DATA_PATH="${ROOT_DIR}"/data
DATE=$(date)
LOG_DATE=${DATE// /_}
TEST_OUTPUT_PATH="${ROOT_DIR}/test_output/"${LOG_DATE//:/_}
# Handle command line options
for i in "$@"; do
  case $i in

  #
  # SKIP_REBUILD_BRO
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

EXTRA_ARGS="$*"

echo "Running build_container with "
echo "SKIP_REBUILD_BRO = $SKIP_REBUILD_BRO"
echo "==================================================="

# Create the network
bash "${SCRIPT_DIR}"/create_docker_network.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Run the zookeeper container
bash "${SCRIPT_DIR}"/docker_run_zookeeper_container.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Wait for zookeeper to be up
bash "${SCRIPT_DIR}"/docker_run_wait_for_zookeeper.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Run the kafka container
bash "${SCRIPT_DIR}"/docker_run_kafka_container.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Wait for kafka to be up
bash "${SCRIPT_DIR}"/docker_run_wait_for_kafka.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Create the bro topic
bash "${SCRIPT_DIR}"/docker_run_create_bro_topic_in_kafka.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Build the bro container
if [[ "$SKIP_REBUILD_BRO" = false ]]; then
  bash "${SCRIPT_DIR}"/build_container.sh \
   --container-directory="${CONTAINER_DIR}" \
   --container-name=metron-bro-docker-container:latest

  rc=$?; if [[ ${rc} != 0 ]]; then
    exit ${rc}
  fi
fi

# Download the pcaps
bash "${SCRIPT_DIR}"/download_sample_pcaps.sh --data-path="${DATA_PATH}"

mkdir "${TEST_OUTPUT_PATH}" || exit 1

# Run the bro container and optionally the passed script _IN_ the container
bash "${SCRIPT_DIR}"/docker_run_bro_container.sh \
  --data-path="${DATA_PATH}" \
  --test-output-path="${TEST_OUTPUT_PATH}" \
  "$EXTRA_ARGS"

rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Build the bro plugin
bash "${SCRIPT_DIR}"/docker_execute_build_bro_plugin.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR> FAILED TO BUILD PLUGIN.  CHECK LOGS  ${rc}"
  exit ${rc}
fi

# Configure the bro plugin
bash "${SCRIPT_DIR}"/docker_execute_configure_bro_plugin.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR> FAILED TO CONFIGURE PLUGIN.  CHECK LOGS  ${rc}"
  exit ${rc}
fi


# for each pcap in the data directory, we want to
# run bro then read the output from kafka
# and output both of them to the same directory named
# for the date/pcap


for file in "${DATA_PATH}"/**/*.pcap*
do
  # get the file name
  BASE_FILE_NAME=$(basename "${file}")
  DOCKER_DIRECTORY_NAME=${BASE_FILE_NAME//\./_}

  mkdir "${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}" || exit 1
  echo "MADE ${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}"

  # get the current offset in kafka
  # this is where we are going to _start_
  OFFSET=$(bash "${SCRIPT_DIR}"/docker_run_get_offset_bro_kafka.sh | sed 's/^bro:0:\(.*\)$/\1/')
  echo "OFFSET------------------> ${OFFSET}"

  bash "${SCRIPT_DIR}"/docker_execute_process_data_file.sh --pcap-file-name="${BASE_FILE_NAME}" --output-directory-name="${DOCKER_DIRECTORY_NAME}"

  rc=$?; if [[ ${rc} != 0 ]]; then
    echo "ERROR> FAILED TO PROCESS ${file} DATA.  CHECK LOGS, please run the finish_end_to_end.sh when you are done."
    exit ${rc}
  fi
  KAFKA_OUTPUT_FILE="${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}/kafka-output.log"
  bash "${SCRIPT_DIR}"/docker_run_consume_bro_kafka.sh --offset=$OFFSET | "${ROOT_DIR}"/remove_timeout_message.sh | tee "${KAFKA_OUTPUT_FILE}"

  rc=$?; if [[ ${rc} != 0 ]]; then
    echo "ERROR> FAILED TO PROCESS ${DATA_PATH} DATA.  CHECK LOGS"
  fi

  "${SCRIPT_DIR}"/split_kakfa_output_by_log.sh --log-directory="${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}"
done

"${SCRIPT_DIR}"/print_results.sh --test-directory="${TEST_OUTPUT_PATH}"

echo ""
echo "Run complete"
echo "The kafka and bro output can be found at ${TEST_OUTPUT_PATH}"
echo "You may now work with the containers if you will.  You need to call finish_end_to_end.sh when you are done"
