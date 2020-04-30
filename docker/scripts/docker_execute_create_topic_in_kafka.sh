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
  echo "    --container-name                [OPTIONAL] The Docker container name. Default: metron-bro-plugin-kafka_kafka_1"
  echo "    --kafka-topic                   [OPTIONAL] The kafka topic to create. Default: zeek"
  echo "    -h/--help                       Usage information."
  echo " "
}

CONTAINER_NAME="metron-bro-plugin-kafka_kafka_1"
KAFKA_TOPIC=zeek

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

echo "Running docker_execute_create_topic_in_kafka.sh with "
echo "CONTAINER_NAME = ${CONTAINER_NAME}"
echo "KAFKA_TOPIC = ${KAFKA_TOPIC}"
echo "==================================================="

docker exec -w /kafka/bin/ "${CONTAINER_NAME}" \
  bash -c "JMX_PORT= ./kafka-topics.sh --create --topic ${KAFKA_TOPIC} --replication-factor 1 --partitions 1 --zookeeper zookeeper:2181"
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi
