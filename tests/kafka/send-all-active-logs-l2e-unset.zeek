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

# @TEST-EXEC: zeek ../../../scripts/Apache/Kafka/ %INPUT > output
# @TEST-EXEC: btest-diff output

module Kafka;

redef send_all_active_logs = T;

print send_to_kafka(HTTP::LOG);
print send_to_kafka(DHCP::LOG);
print send_to_kafka(Conn::LOG);
print send_to_kafka(DNS::LOG);
print send_to_kafka(SMTP::LOG);
print send_to_kafka(SSL::LOG);
print send_to_kafka(Files::LOG);
