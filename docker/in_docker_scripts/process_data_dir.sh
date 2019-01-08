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

#
# For each file in the data directory and sub-directories ( if mapped ), this script will
# run bro -r with the local.bro configuration.
#

cd /root || exit 1
echo "================================" >>"${RUN_LOG_PATH}" 2>&1
if [ ! -d /root/data ]; then
  echo "DATA_PATH has not been set and mapped" >>"${RUN_LOG_PATH}" 2>&1
  exit 1
fi


for file in /root/data/**/*.pcap*
do
  # get the file name
  FILENAME=$(basename $file)
  # replace the . with _
  FILENAME=${FILENAME//\./_}

  # create the directory name with the $LOG_DATE
  LOG_DIR="/root/bro_output/${LOG_DATE}/${FILENAME}"

  # create the directory
  mkdir -p "${LOG_DIR}" || exit 1

  # cd there
  cd "${LOG_DIR}" || exit 1

  # run bro
  bro -r $file /usr/local/bro/share/bro/site/local.bro -C
done

cd /root || exit 1

