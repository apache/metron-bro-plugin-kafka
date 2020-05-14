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
ARG FROM_IMAGE="wurstmeister/kafka"
ARG FROM_IMAGE_TAG="2.12-2.5.0"

FROM "${FROM_IMAGE}":"${FROM_IMAGE_TAG}"

HEALTHCHECK --interval=5s --timeout=10s --start-period=2s --retries=3 \
  CMD JMX_PORT= /opt/kafka/bin/kafka-configs.sh --describe --zookeeper zookeeper:2181 --entity-type brokers || exit 1

