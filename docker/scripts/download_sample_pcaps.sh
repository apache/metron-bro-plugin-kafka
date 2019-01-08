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
# Downloads sample pcap files to the data directory
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --data-path                    [REQURIED] The pcap data path"
  echo "    -h/--help                      Usage information."
  echo " "
  echo " "
}

DATA_PATH=

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # DATA_PATH
  #
  #   --data-path
  #
    --data-path=*)
      DATA_PATH="${i#*=}"
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

if [[ -z "$DATA_PATH" ]]; then
  echo "DATA_PATH must be passed"
  exit 1
fi

echo "Running download_sample_pcaps with "
echo "DATA_PATH = $DATA_PATH"
echo "==================================================="

for folder in nitroba example-traffic ssh ftp radius rfb; do
  if [[ ! -d "${DATA_PATH}"/${folder} ]]; then
    mkdir -p "${DATA_PATH}"/${folder}
  fi
done

if [[ ! -f "${DATA_PATH}"/example-traffic/exercise-traffic.pcap ]]; then
  wget https://www.bro.org/static/traces/exercise-traffic.pcap -O "${DATA_PATH}"/example-traffic/exercise-traffic.pcap
fi

if [[ ! -f "${DATA_PATH}"/nitroba/nitroba.pcap ]]; then
  wget http://downloads.digitalcorpora.org/corpora/network-packet-dumps/2008-nitroba/nitroba.pcap -O "${DATA_PATH}"/nitroba/nitroba.pcap
fi

if [[ ! -f "${DATA_PATH}"/ssh/ssh.pcap ]]; then
  wget https://www.bro.org/static/traces/ssh.pcap -O "${DATA_PATH}"/ssh/ssh.pcap
fi

if [[ ! -f "${DATA_PATH}"/ftp/ftp.pcap ]]; then
  wget https://github.com/markofu/pcaps/blob/master/PracticalPacketAnalysis/ppa-capture-files/ftp.pcap?raw=true -O "${DATA_PATH}"/ftp/ftp.pcap
fi

if [[ ! -f "${DATA_PATH}"/radius/radius_localhost.pcapng ]]; then
  wget https://github.com/EmpowerSecurityAcademy/wireshark/blob/master/radius_localhost.pcapng?raw=true -O "${DATA_PATH}"/radius/radius_localhost.pcapng
fi

if [[ ! -f "${DATA_PATH}"/rfb/rfb.pcap ]]; then
  wget https://github.com/kholia/my-pcaps/blob/master/VNC/07-vnc-openwall-3.7.pcap?raw=true -O "${DATA_PATH}"/rfb/rfb.pcap
fi

