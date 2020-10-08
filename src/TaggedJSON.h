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

#ifndef ZEEK_PLUGIN_BRO_KAFKA_TAGGEDJSON_H
#define ZEEK_PLUGIN_BRO_KAFKA_TAGGEDJSON_H

#include <Desc.h>
#include <map>
#include <string>
#include <threading/Formatter.h>
#include <threading/formatters/JSON.h>

using threading::Field;
using threading::MsgThread;
using threading::Value;
using threading::formatter::JSON;

namespace threading {
namespace formatter {

/*
 * A JSON formatter that prepends or 'tags' the content with a log stream
 * identifier.  For example,
 *   { 'conn' : { ... }}
 *   { 'http' : { ... }}
 */
class TaggedJSON : public JSON {
public:
  TaggedJSON(std::string stream_name, MsgThread *t, JSON::TimeFormat tf);
  virtual ~TaggedJSON();
  virtual bool Describe(ODesc *desc, int num_fields, const Field *const *fields,
                        Value **vals, std::map<std::string, std::string> &const_vals) const;

private:
  std::string stream_name;
};

} // namespace formatter
} // namespace threading
#endif
