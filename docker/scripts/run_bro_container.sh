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

function help {
 echo " "
 echo "usage: ${0}"
 echo "    --container-path                [REQUIRED] The path with the Dockerfile"
 echo "    --container-name                [REQURIED] The name to give the container"
 echo "    --network-name                  [REQUIRED] The docker network name"
 echo "    --scripts-path                  [OPTIONAL] The path with the scripts you may run in the container"
 echo "    --script-name                   [OPTIONAL] The name of the script in the scripts directory to run, " \
                                            "if not provided we will just drop into shell (not bro will not be built) " \
                                            "and you will have to run /root/built_in_scripts/build_bro.sh yourself"
 echo "    --data-path                     [OPTIONAL] The name of the directory to map to /root/data"
 echo "    --log-path                      [REQUIRED] The path to log to"
 echo "    --docker-parameter              [OPTIONAL] Each parameter with this name will be passed to docker run"
 echo "    -h/--help                       Usage information."
 echo " "
 echo "example: to skip vagrant up and force docker build with two tags"
 echo "   build-container.sh --container-path ./bro --container-name bro-docker-container"
 echo " "
}

BRO_PLUGIN_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && cd ../.. && pwd )"
CONTAINER_PATH=
CONTAINER_NAME=
NETWORK_NAME=
OUR_SCRIPTS_PATH="${BRO_PLUGIN_PATH}/docker/in_docker_scripts"
LOG_PATH=
SCRIPTS_PATH=
SCRIPT_NAME=
DATA_PATH=

declare -a DOCKER_PARAMETERS

# handle command line options
for i in "$@"; do
 case $i in
 #
 # CONTAINER_PATH
 #
 #
  --container-path=*)
   CONTAINER_PATH="${i#*=}"
   shift # past argument=value
  ;;

 #
 # CONTAINER_NAME
 #
 #
 #
   --container-name=*)
   CONTAINER_NAME="${i#*=}"
   shift # past argument=value
  ;;

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
 # LOG_PATH
 #
 #
 #
  --log-path=*)
    LOG_PATH="${i#*=}"
    shift # past argument=value
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
 # SCRIPTS_PATH
 #
 #
  --scripts-path=*)
   SCRIPTS_PATH="${i#*=}"
   shift # past argument=value
  ;;

 #
 # SCRIPT_NAME
 #
 #
 --script-name=*)
  SCRIPT_NAME="${i#*=}"
  shift # past argument=value
 ;;

 #
 # DOCKER_PARAMETERS
 #
 #
  --docker-parameter=*)
   DOCKER_PARAMETERS=("${DOCKER_PARAMETERS[@]}" "${i#*=}")
   shift # past argument=value
 ;;

 #
 # -h/--help
 #
  -h|--help)
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

if [[ -z "$CONTAINER_PATH" ]]; then
  echo "CONTAINER_PATH must be passed"
  exit 1
fi

if [[ -z "$CONTAINER_NAME" ]]; then
  echo "CONTAINER_NAME must be passed"
  exit 1
fi
if [[ -z "$NETWORK_NAME" ]]; then
  echo "NETWORK_NAME must be passed"
  exit 1
fi

if [[ -z "$LOG_PATH" ]]; then
  echo "LOG_PATH must be passed"
  exit 1
fi

echo "Running with "
echo "CONTAINER_PATH = $CONTAINER_PATH"
echo "CONTAINER_NAME = $CONTAINER_NAME"
echo "NETWORK_NAME = ${NETWORK_NAME}"
echo "SCRIPT_PATH = $SCRIPTS_PATH"
echo "SCRIPT_NAME = $SCRIPT_NAME"
echo "LOG_PATH = $LOG_PATH"
echo "DATA_PATH = $DATA_PATH"
echo "DOCKER_PARAMETERS = " "${DOCKER_PARAMETERS[@]}"
echo "==================================================="

# move over to the docker area
cd "${CONTAINER_PATH}" || exit 1

DATE=$(date)
LOG_DATE=${DATE// /_}
LOGNAME="bro-test-${LOG_DATE}.log"
echo "Log will be found on host at ${LOG_PATH}/$LOGNAME"

#build the docker command line
declare -a DOCKER_CMD_BASE
DOCKER_CMD="bash"
DOCKER_CMD_BASE[0]="docker run -it --network ${NETWORK_NAME} "
DOCKER_CMD_BASE[1]="-e RUN_LOG_PATH=\"/root/logs/${LOGNAME}\" "
DOCKER_CMD_BASE[2]="-v \"${LOG_PATH}:/root/logs\" "
DOCKER_CMD_BASE[3]="-v \"${OUR_SCRIPTS_PATH}:/root/built_in_scripts\" "
DOCKER_CMD_BASE[4]="-v \"${BRO_PLUGIN_PATH}:/root/code\" "
if [[ ! -z "$SCRIPTS_PATH" ]]; then
  DOCKER_CMD_BASE[5]="-v \"${SCRIPTS_PATH}:/root/scripts\" "
fi
if [[ ! -z "$DATA_PATH" ]]; then
  DOCKER_CMD_BASE[6]="-v \"${DATA_PATH}:/root/data\" "
fi

if [[ ! -z "$SCRIPT_NAME" ]]; then
  DOCKER_CMD="bash -c \"/root/built_in_scripts/build_bro.sh\" && \"/root/scripts/${SCRIPT_NAME}\""
fi
echo "===============Running Docker==============="
echo "cmd is eval" "${DOCKER_CMD_BASE[@]}" "${DOCKER_PARAMETERS[@]}" "${CONTAINER_NAME}" "${DOCKER_CMD}"
echo ""
echo ""
echo ""
eval "${DOCKER_CMD_BASE[@]}" "${DOCKER_PARAMETERS[@]}" "${CONTAINER_NAME}" "${DOCKER_CMD}"

rc=$?; if [[ ${rc} != 0 ]]; then
 exit ${rc};
fi
