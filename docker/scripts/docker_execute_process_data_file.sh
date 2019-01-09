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
# Executes the process_data_dir.sh script in the container
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --container-name                [OPTIONAL] The Docker container name. Default: bro"
  echo "    --pcap-file-name                [REQUIRED] The name of the pcap file"
  echo "    --output-directory-name         [REQUIRED] The name of the output directory"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

CONTAINER_NAME=bro
PCAP_FILE_NAME=
OUTPUT_DIRECTORY_NAME=

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # CONTAINER_NAME
  #
  #   --container-name
  #
    --container-name=*)
      CONTAINER_NAME="${i#*=}"
      shift # past argument=value
    ;;

  #
  # PCAP_FILE_NAME
  #
  #   --pcap-file-name
  #
    --pcap-file-name=*)
      PCAP_FILE_NAME="${i#*=}"
      shift # past argument=value
    ;;

  #
  # OUTPUT_DIRECTORY_NAME
  #
  #   --output-directory-name
  #
    --output-directory-name=*)
      OUTPUT_DIRECTORY_NAME="${i#*=}"
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

echo "Running docker_execute_process_data_dir with "
echo "CONTAINER_NAME = $CONTAINER_NAME"
echo "PCAP_FILE_NAME = ${PCAP_FILE_NAME}"
echo "OUTPUT_DIRECTORY_NAME = ${OUTPUT_DIRECTORY_NAME}"
echo "==================================================="

echo "executing process_data_file.sh in the bro docker container"
echo " "

docker exec -w /root "${CONTAINER_NAME}" bash -c "built_in_scripts/process_data_file.sh --pcap-file-name=${PCAP_FILE_NAME} --output-directory-name=${OUTPUT_DIRECTORY_NAME}"

rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc};
fi

echo "done processing ${PCAP_FILE_NAME}"