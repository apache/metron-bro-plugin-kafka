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

TaggedJSON::TaggedJSON(std::string sn, MsgThread* t, JSON::TimeFormat tf): JSON(t, tf), stream_name(sn)
{}

TaggedJSON::~TaggedJSON()
{}

bool TaggedJSON::Describe(ODesc* desc, int num_fields, const Field* const* fields, Value** vals, std::map<std::string,std::string> &const_vals) const
{
    desc->AddRaw("{");

    // 'tag' the json; aka prepend the stream name to the json-formatted log content
    desc->AddRaw("\"");
    desc->AddRaw(stream_name);
    desc->AddRaw("\": ");



    // append the JSON formatted log record itself
    JSON::Describe(desc, num_fields, fields, vals);
    if (const_vals.size() > 0) {

      std::map<std::string, std::string>::iterator it = const_vals.begin();
      while (it != const_vals.end()) {
        desc->AddRaw(",");
        desc->AddRaw("\"");
        desc->AddRaw(it->first);
        desc->AddRaw("\": ");
        desc->AddRaw("\"");
        desc->AddRaw(it->second);
        desc->AddRaw("\"");
        it++;
      }
    }

  desc->AddRaw("}");
    return true;
}
} // namespace formatter
} // namespace threading
