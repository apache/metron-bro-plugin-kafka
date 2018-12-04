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

cd /root || exit 1
echo "================================" >> "${RUN_LOG_PATH}" 2>&1
bro-pkg install code --force | tee "${RUN_LOG_PATH}"
echo "================================" >> "${RUN_LOG_PATH}" 2>&1

echo "================================" >> "${RUN_LOG_PATH}" 2>&1
bro -N Apache::Kafka | tee v
echo "================================" >> "${RUN_LOG_PATH}" 2>&1

echo "@load packages" >> /usr/local/bro/share/bro/site/local.bro
echo "redef Kafka::logs_to_send = set(HTTP::LOG, DNS::LOG, Conn::LOG, DPD::LOG, FTP::LOG, Files::LOG, Known::CERTS_LOG, SMTP::LOG, SSL::LOG, Weird::LOG, Notice::LOG, DHCP::LOG, SSH::LOG, Software::LOG, RADIUS::LOG, X509::LOG, Known::DEVICES_LOG, RFB::LOG, Stats::LOG, CaptureLoss::LOG, SIP::LOG);/'" >> /usr/local/bro/share/bro/site/local.bro
echo "redef Kafka::topic_name = \"bro\";" >> /usr/local/bro/share/bro/site/local.bro
echo "redef Kafka::tag_json = T;" >> /usr/local/bro/share/bro/site/local.bro
echo "redef Kafka::kafka_conf = table([\"metadata.broker.list\"] = \"kafka:9092\");" >> /usr/local/bro/share/bro/site/local.bro
echo "redef Kafka::logs_to_exclude = set(Conn::LOG, DHCP::LOG);" >> /usr/local/bro/share/bro/site/local.bro
echo "redef Known::cert_tracking = ALL_HOSTS;" >> /usr/local/bro/share/bro/site/local.bro
echo "redef Software::asset_tracking = ALL_HOSTS;" >> /usr/local/bro/share/bro/site/local.bro
sed -i '86 a @load policy/protocols/dhcp/known-devices-and-hostnames.bro' /usr/local/bro/share/bro/site/local.bro
