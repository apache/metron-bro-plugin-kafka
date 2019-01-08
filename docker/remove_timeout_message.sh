#! /usr/bin/env bash
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

#
# remove the exception text from piped input when we have purposefully timed
# out reading kafka
#

LAST_CMD=
SKIP_EXCEPTION_TEXT=false
while read -r CMD; do
    if [[ ${CMD} =~ ('ERROR Error processing message') ]]; then
        LAST_CMD=${CMD}
    elif [[ ${CMD} =~ ('kafka.consumer.ConsumerTimeoutException') ]]; then
        SKIP_EXCEPTION_TEXT=true
    elif [[ "$SKIP_EXCEPTION_TEXT" = true ]]; then
        if [[ ! ${CMD} =~ (^at) ]]; then
            echo "${CMD}"
        fi
    else
        if [[ -n "$LAST_CMD" ]]; then
            LAST_CMD=
        fi
        if [[ ! ${CMD} =~ (^--) ]]; then
            echo "${CMD}"
        fi
    fi
done
