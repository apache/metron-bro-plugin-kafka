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
# Prints all the results.csv files
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --test-directory           [REQUIRED] The directory for the tests"
  echo "    -h/--help                   Usage information."
  echo " "
  echo " "
}

TEST_DIRECTORY=

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # TEST_DIRECTORY
  #
  #   --test-directory
  #
    --test-directory=*)
      TEST_DIRECTORY="${i#*=}"
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

if [[ -z "$TEST_DIRECTORY" ]]; then
  echo "$TEST_DIRECTORY must be passed"
  exit 1
fi


echo "Running with "
echo "TEST_DIRECTORY = $TEST_DIRECTORY"
echo "==================================================="

# Move over to the docker area
cd "${TEST_DIRECTORY}" || exit 1
RESULTS_FILES=$(find "${TEST_DIRECTORY}" -name "results.csv")
for file in $RESULTS_FILES; do
  echo "-->" "${file}"
  column -t -s ',' "$file"
  echo -e "========================================================\n"
  awk -F\, 'FNR > 1 && $2 != $3 {print "ERROR> The " $1 " bro and kafka log counts do not match for " FILENAME; exit 1}' "${file}"
done

