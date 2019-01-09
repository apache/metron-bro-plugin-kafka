#!/usr/bin/env bash
# shellcheck disable=SC2143,SC1083,SC2002,SC2126

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

#
# For a given directory, finds all the bro log output, and splits the kafka output file
# by bro log, such that there is a bro log -> bro log kafka log
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --log-directory                 [REQUIRED] The directory with the logs"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

LOG_DIRECTORY=

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # LOG_DIRECTORY
  #
  #   --log-directory
  #
    --log-directory=*)
      LOG_DIRECTORY="${i#*=}"
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

if [[ -z "$LOG_DIRECTORY" ]]; then
  echo "$LOG_DIRECTORY must be passed"
  exit 1
fi

echo "Running with "
echo "$LOG_DIRECTORY = $LOG_DIRECTORY"
echo "==================================================="

# Move over to the docker area
cd "${LOG_DIRECTORY}" || exit 1

# for each log file, that is NOT KAFKA_OUTPUT_FILE we want to get the name
# and extract the start
# then we want to grep that name > name.kafka.log from the KAFKA_OUTPUT_FILE
RESULTS_FILE="${LOG_DIRECTORY}/results.csv"
echo "LOG,BRO_COUNT,KAFKA_COUNT" >> "${RESULTS_FILE}"
for log in "${LOG_DIRECTORY}"/*.log
do
  BASE_LOG_FILE_NAME=$(basename "$log" .log)
  if [[ ! "$BASE_LOG_FILE_NAME" == "kafka-output.log" ]]; then
    echo "${BASE_LOG_FILE_NAME}"
    if [[ $(grep {\""${BASE_LOG_FILE_NAME}"\": "${LOG_DIRECTORY}"/kafka-output.log) ]]; then
      grep {\""${BASE_LOG_FILE_NAME}"\": "${LOG_DIRECTORY}"/kafka-output.log > "${LOG_DIRECTORY}"/"${BASE_LOG_FILE_NAME}".kafka.log

      KAKFA_COUNT=$(cat "${LOG_DIRECTORY}/${BASE_LOG_FILE_NAME}.kafka.log" | wc -l)
      BRO_COUNT=$(grep -v "#" "${log}" | wc -l)

      echo "${BASE_LOG_FILE_NAME},${BRO_COUNT},${KAKFA_COUNT}" >> "${RESULTS_FILE}"
    fi
  fi
done

