#!/usr/bin/env bash
# shellcheck disable=SC2010

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
set -e # errexit
set -E # errtrap
set -o pipefail

PCAP_FILE_NAME=
OUTPUT_DIRECTORY_NAME=

# Handle command line options
for i in "$@"; do
  case $i in
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
  # Unknown option
  #
    *)
      UNKNOWN_OPTION="${i#*=}"
      echo "Error: unknown option: $UNKNOWN_OPTION"
      help
    ;;
  esac
done

echo "PCAP_FILE_NAME = ${PCAP_FILE_NAME}"
echo "OUTPUT_DIRECTORY_NAME = ${OUTPUT_DIRECTORY_NAME}"

cd /root || exit 1
echo "================================" >>"${RUN_LOG_PATH}" 2>&1
if [ ! -d /root/data ]; then
  echo "DATA_PATH has not been set and mapped" >>"${RUN_LOG_PATH}" 2>&1
  exit 1
fi
cd /root/test_output/"${OUTPUT_DIRECTORY_NAME}" || exit 1
find /root/data -type f -name "${PCAP_FILE_NAME}" -exec echo "processing" '{}' \; -exec bro -r '{}' /usr/local/bro/share/bro/site/local.bro -C \;
echo "done with ${PCAP_FILE_NAME}"
