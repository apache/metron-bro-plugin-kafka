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
set -E # errtrap
set -o pipefail

function help {
  echo " "
  echo "USAGE"
  echo "    --skip-docker-build             [OPTIONAL] Skip build of zeek docker machine."
  echo "    --data-path                     [OPTIONAL] The pcap data path. Default: ./data"
  echo "    --kafka-topic                   [OPTIONAL] The kafka topic to consume from. Default: zeek"
  echo "    --partitions                    [OPTIONAL] The number of kafka partitions to create. Default: 2"
  echo "    --plugin-version                [OPTIONAL] The plugin version. Default: the current branch name"
  echo "    --no-pcap                       [OPTIONAL] Do not run pcaps."
  echo "    -h/--help                       Usage information."
  echo " "
  echo "COMPATABILITY"
  echo "     bash >= 4.0 is required."
  echo " "
}

# Require bash >= 4
if (( BASH_VERSINFO[0] < 4 )); then
  >&2 echo "ERROR> bash >= 4.0 is required" >&2
  help
  exit 1
fi

SKIP_REBUILD_ZEEK=false
NO_PCAP=false
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
PLUGIN_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. > /dev/null && pwd)"
SCRIPT_DIR="${ROOT_DIR}"/scripts
DATA_PATH="${ROOT_DIR}"/data
DATE=$(date)
LOG_DATE=${DATE// /_}
TEST_OUTPUT_PATH="${ROOT_DIR}/test_output/"${LOG_DATE//:/_}
KAFKA_TOPIC="zeek"
PARTITIONS=2
PROJECT_NAME="metron-bro-plugin-kafka"
OUR_SCRIPTS_PATH="${PLUGIN_ROOT_DIR}/docker/in_docker_scripts"

cd "${PLUGIN_ROOT_DIR}" || { echo "NO PLUGIN ROOT" ; exit 1; }
# we may not be checked out from git, check and make it so that we are since
# zkg requires it

git status &>/dev/null
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "zkg requires the plugin to be a git repo, creating..."
  git init .
  rc=$?; if [[ ${rc} != 0 ]]; then
    echo "ERROR> FAILED TO INITIALIZE GIT IN PLUGIN DIRECTORY. ${rc}"
  exit ${rc}
  fi
  git add .
  rc=$?; if [[ ${rc} != 0 ]]; then
    echo "ERROR> FAILED TO ADD ALL TO GIT PLUGIN DIRECTORY. ${rc}"
  exit ${rc}
  fi
  git commit -m 'docker run'
  rc=$?; if [[ ${rc} != 0 ]]; then
    echo "ERROR> FAILED TO COMMIT TO GIT MASTER IN PLUGIN DIRECTORY. ${rc}"
  exit ${rc}
  fi
  echo "git repo created"
fi

# set errexit for the rest of the run
set -e

PLUGIN_VERSION=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # SKIP_REBUILD_ZEEK
  #
  #   --skip-docker-build
  #
    --skip-docker-build)
      SKIP_REBUILD_ZEEK=true
      shift # past argument
    ;;
  #
  # NO_PCAP
  #
  #   --no-pcap
  #
    --no-pcap)
      NO_PCAP=true
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
  # KAFKA_TOPIC
  #
  #   --kafka-topic
  #
    --kafka-topic=*)
      KAFKA_TOPIC="${i#*=}"
      shift # past argument=value
    ;;
  #
  # PARTITIONS
  #
  #   --partitions
  #
    --partitions=*)
      PARTITIONS="${i#*=}"
      shift # past argument=value
    ;;
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
  esac
done

cd "${ROOT_DIR}" || { echo "ROOT_DIR unavailable" ; exit 1; }
echo "Running the end to end tests with"
echo "COMPOSE_PROJECT_NAME = ${PROJECT_NAME}"
echo "SKIP_REBUILD_ZEEK    = ${SKIP_REBUILD_ZEEK}"
echo "KAFKA_TOPIC          = ${KAFKA_TOPIC}"
echo "PARTITIONS           = ${PARTITIONS}"
echo "PLUGIN_VERSION       = ${PLUGIN_VERSION}"
echo "DATA_PATH            = ${DATA_PATH}"
echo "TEST_OUTPUT_PATH     = ${TEST_OUTPUT_PATH}"
echo "PLUGIN_ROOT_DIR      = ${PLUGIN_ROOT_DIR}"
echo "OUR_SCRIPTS_PATH     = ${OUR_SCRIPTS_PATH}"
echo "==================================================="

# Run docker compose, rebuilding as specified
if [[ "$SKIP_REBUILD_ZEEK" = false ]]; then
  COMPOSE_PROJECT_NAME="${PROJECT_NAME}" \
    DATA_PATH=${DATA_PATH} \
    TEST_OUTPUT_PATH=${TEST_OUTPUT_PATH} \
    PLUGIN_ROOT_DIR=${PLUGIN_ROOT_DIR} \
    OUR_SCRIPTS_PATH=${OUR_SCRIPTS_PATH} \
    docker-compose up -d --build
  rc=$?; if [[ ${rc} != 0 ]]; then
    exit ${rc}
  fi
else
  COMPOSE_PROJECT_NAME="${PROJECT_NAME}" \
    DATA_PATH=${DATA_PATH} \
    TEST_OUTPUT_PATH=${TEST_OUTPUT_PATH} \
    PLUGIN_ROOT_DIR=${PLUGIN_ROOT_DIR} \
    OUR_SCRIPTS_PATH=${OUR_SCRIPTS_PATH} \
    docker-compose up -d
  rc=$?; if [[ ${rc} != 0 ]]; then
    exit ${rc}
  fi
fi

# Create the kafka topic
bash "${SCRIPT_DIR}"/docker_execute_create_topic_in_kafka.sh --kafka-topic="${KAFKA_TOPIC}" --partitions="${PARTITIONS}"
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi

# Download the pcaps
bash "${SCRIPT_DIR}"/download_sample_pcaps.sh --data-path="${DATA_PATH}"
# By not catching $? here we are accepting that a failed pcap download will not
# exit the script

# Build the zeek plugin
bash "${SCRIPT_DIR}"/docker_execute_build_plugin.sh --plugin-version="${PLUGIN_VERSION}"
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR> FAILED TO BUILD PLUGIN.  CHECK LOGS  ${rc}"
  exit ${rc}
fi

# Configure the plugin
bash "${SCRIPT_DIR}"/docker_execute_configure_plugin.sh --kafka-topic="${KAFKA_TOPIC}"
rc=$?; if [[ ${rc} != 0 ]]; then
  echo "ERROR> FAILED TO CONFIGURE PLUGIN.  CHECK LOGS  ${rc}"
  exit ${rc}
fi

if [[ "$NO_PCAP" = false ]]; then
  # for each pcap in the data directory, we want to
  # run zeek then read the output from kafka
  # and output both of them to the same directory named
  # for the date/pcap


  for file in "${DATA_PATH}"/**/*.pcap*
  do
    # get the file name
    BASE_FILE_NAME=$(basename "${file}")
    DOCKER_DIRECTORY_NAME=${BASE_FILE_NAME//\./_}

    mkdir "${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}" || exit 1
    echo "MADE ${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}"

    # get the offsets in kafka for the provided topic
    # this is where we are going to _start_
    OFFSETS=$(bash "${SCRIPT_DIR}"/docker_run_get_offset_kafka.sh --kafka-topic="${KAFKA_TOPIC}")

    # loop through each partition
    while IFS= read -r line; do
      # shellcheck disable=SC2001
      OFFSET=$(echo "${line}" | sed "s/^${KAFKA_TOPIC}:.*:\(.*\)$/\1/")
      # shellcheck disable=SC2001
      PARTITION=$(echo "${line}" | sed "s/^${KAFKA_TOPIC}:\(.*\):.*$/\1/")
      echo "PARTITION---------------> ${PARTITION}"
      echo "OFFSET------------------> ${OFFSET}"

      bash "${SCRIPT_DIR}"/docker_execute_process_data_file.sh --pcap-file-name="${BASE_FILE_NAME}" --output-directory-name="${DOCKER_DIRECTORY_NAME}"
      rc=$?; if [[ ${rc} != 0 ]]; then
        echo "ERROR> FAILED TO PROCESS ${file} DATA.  CHECK LOGS, please run the finish_end_to_end.sh when you are done."
        exit ${rc}
      fi

      KAFKA_OUTPUT_FILE="${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}/kafka-output.log"
      bash "${SCRIPT_DIR}"/docker_run_consume_kafka.sh --offset="${OFFSET}" --partition="${PARTITION}" --kafka-topic="${KAFKA_TOPIC}" | "${ROOT_DIR}"/remove_timeout_message.sh | tee -a "${KAFKA_OUTPUT_FILE}"
      rc=$?; if [[ ${rc} != 0 ]]; then
        echo "ERROR> FAILED TO PROCESS ${DATA_PATH} DATA.  CHECK LOGS"
      fi
    done <<< "${OFFSETS}"

    "${SCRIPT_DIR}"/split_kafka_output_by_log.sh --log-directory="${TEST_OUTPUT_PATH}/${DOCKER_DIRECTORY_NAME}"
    rc=$?; if [[ ${rc} != 0 ]]; then
      echo "ERROR> ISSUE ENCOUNTERED WHEN SPLITTING KAFKA OUTPUT LOGS"
    fi
  done

  "${SCRIPT_DIR}"/print_results.sh --test-directory="${TEST_OUTPUT_PATH}"
  rc=$?; if [[ ${rc} != 0 ]]; then
    echo "ERROR> ISSUE ENCOUNTERED WHEN PRINTING RESULTS"
    exit ${rc}
  fi

  "${SCRIPT_DIR}"/analyze_results.sh --test-directory="${TEST_OUTPUT_PATH}"
  rc=$?; if [[ ${rc} != 0 ]]; then
    echo "ERROR> ISSUE ENCOUNTERED WHEN ANALYZING RESULTS"
    exit ${rc}
  fi
fi
echo ""
echo "Run complete"
echo "The kafka and zeek output can be found at ${TEST_OUTPUT_PATH}"
echo "You may now work with the containers if you will.  You need to call finish_end_to_end.sh when you are done"
