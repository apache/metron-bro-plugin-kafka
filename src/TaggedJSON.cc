/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "TaggedJSON.h"

namespace threading { namespace formatter {

TaggedJSON::TaggedJSON(string srn, string sn, MsgThread* t, JSON::TimeFormat tf): JSON(t, tf), sensor_name(srn), stream_name(sn)
{}

TaggedJSON::~TaggedJSON()
{}

bool TaggedJSON::Describe(ODesc* desc, int num_fields, const Field* const* fields, Value** vals) const
{
    desc->AddRaw("{");

    // 'tag' the json; aka prepend the sensor name
    desc->AddRaw("\"sensor_name\": \"");
    desc->AddRaw(sensor_name);
    desc->AddRaw("\", ");

    // 'tag' the json; aka prepend the sensor name
    desc->AddRaw("\"event_type\": \"");
    desc->AddRaw(stream_name);
    desc->AddRaw("\", ");

    desc->AddRaw("\"data\": ");

    // append the JSON formatted log record itself
    JSON::Describe(desc, num_fields, fields, vals);

    desc->AddRaw("}");
    return true;
}
}}
