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
# run's docker build in a provided directory, with a provided name
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --container-directory           [REQUIRED] The directory with the Dockerfile"
  echo "    --container-name                [REQUIRED] The name to give the Docker container"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

CONTAINER_DIRECTORY=
CONTAINER_NAME=

# handle command line options
for i in "$@"; do
  case $i in
  #
  # CONTAINER_DIRECTORY
  #
  #
    --container-directory=*)
      CONTAINER_DIRECTORY="${i#*=}"
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

if [[ -z "$CONTAINER_DIRECTORY" ]]; then
  echo "CONTAINER_DIRECTORY must be passed"
  exit 1
fi

if [[ -z "$CONTAINER_NAME" ]]; then
  echo "CONTAINER_NAME must be passed"
  exit 1
fi

echo "Running with "
echo "CONTAINER_DIRECTORY = $CONTAINER_DIRECTORY"
echo "CONTAINER_NAME = $CONTAINER_NAME"
echo "==================================================="

# move over to the docker area
cd "${CONTAINER_DIRECTORY}" || exit 1
pwd
echo "==================================================="
echo "docker build of ${CONTAINER_NAME}"
echo "==================================================="
docker build . --no-cache --tag="${CONTAINER_NAME}"

rc=$?; if [[ ${rc} != 0 ]]; then
  exit ${rc}
fi
