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

##! Load this script to enable log output to kafka

module Kafka;


function send_to_kafka(id: Log::ID): bool
{
        if (|logs_to_send| == 0 && send_all_active_logs == F)
                # Send nothing unless it's explicitly set to send
                return F;
        else if (id in logs_to_exclude ||
                (|logs_to_send| > 0 && id !in logs_to_send && send_all_active_logs == F))
                # Don't send logs in the exclusion set
                return F;
        else
		# If send_all_active_logs is True, send all logs except those
		# in the exclusion set.  Otherwise, send only the logs that are
		# in the inclusion set, but not the exclusions set
                return T;
}

event zeek_init() &priority=-10
{
        for (stream_id in Log::active_streams)
        {
                if (send_to_kafka(stream_id))
                {
                        local filter: Log::Filter = [
                                $name = fmt("kafka-%s", stream_id),
                                $writer = Log::WRITER_KAFKAWRITER,
                                $config = table(["stream_id"] = fmt("%s", stream_id))
                        ];
        
                        Log::add_filter(stream_id, filter);
                }
        }
}

event kafka_topic_resolved_event(topic: string) {
    print(fmt("Kafka topic set to %s",topic));
}
