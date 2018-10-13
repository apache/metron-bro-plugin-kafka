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

module Kafka;

export {
        ## Send all active logs to kafka except for those that are explicitly
        ## excluded via logs_to_exclude.
        ##
        ## Example:  redef Kafka::send_all_active_logs = T;
        const send_all_active_logs: bool = F &redef;

        ## Specify which :bro:type:`Log::ID` to send to kafka.
        ##
        ## Example:  redef Kafka::logs_to_send = set(Conn::Log, DNS::LOG);
        const logs_to_send: set[Log::ID] &redef;

        ## Specify which :bro:type:`Log::ID` to exclude from being sent to kafka.
        ##
        ## Example:  redef Kafka::logs_to_exclude = set(SSH::LOG);
        const logs_to_exclude: set[Log::ID] &redef;

        ## Specify a different timestamp format.
        ##
        ## Example:  redef Kafka::json_timestamps = JSON::TS_ISO8601;
        const json_timestamps: JSON::TimestampFormat = JSON::TS_EPOCH &redef;

        ## Destination kafka topic name
        const topic_name: string = "bro" &redef;

        ## Maximum wait on shutdown in milliseconds
        const max_wait_on_shutdown: count = 3000 &redef;

        ## Whether or not to tag JSON with a log stream identifier
        const tag_json: bool = F &redef;

        ## Any additional configs to pass to librdkafka
        const kafka_conf: table[string] of string = table(
                ["metadata.broker.list"] = "localhost:9092"
        ) &redef;

        ## A comma separated list of librdkafka debug contexts
        const debug: string = "" &redef;
}

