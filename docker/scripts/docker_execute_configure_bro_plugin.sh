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

#
# Executes the configure_bro_plugin.sh in the docker container
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --container-name                [OPTIONAL] The Docker container name. Default: bro"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

CONTAINER_NAME=bro

# handle command line options
for i in "$@"; do
  case $i in
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

echo "Running docker_execute_configure_bro_plugin with "
echo "CONTAINER_NAME = $CONTAINER_NAME"
echo "==================================================="


docker exec -w /root "${CONTAINER_NAME}" bash -c /root/built_in_scripts/configure_bro_plugin.sh
rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc};
fi
echo "configured the bro kafka plugin"
