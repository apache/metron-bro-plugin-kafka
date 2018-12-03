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

cd /root/code || exit 1
echo "================================" >> $RUN_LOG_PATH 2>&1
./configure --bro-dist=/root/bro-2.5.5/  | tee $RUN_LOG_PATH
echo "================================" >> $RUN_LOG_PATH 2>&1
make | tee $RUN_LOG_PATH
echo "================================" >> $RUN_LOG_PATH 2>&1
make install | tee $RUN_LOG_PATH
echo "================================" >> $RUN_LOG_PATH 2>&1
bro -N Apache::Kafka | tee $RUN_LOG_PATH
echo "================================" >> $RUN_LOG_PATH 2>&1
