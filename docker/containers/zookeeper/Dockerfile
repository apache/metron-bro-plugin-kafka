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
ARG FROM_IMAGE="zookeeper"
ARG FROM_IMAGE_TAG="3.4"

FROM "${FROM_IMAGE}":"${FROM_IMAGE_TAG}"

HEALTHCHECK --interval=2s --timeout=1s --start-period=.5s --retries=4 \
  CMD echo ruok | nc localhost 2181 && echo stat | nc localhost 2181 | grep Mode || exit 1

