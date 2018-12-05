<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

## Docker support for testing metron-bro-plugin-kafka

These scripts and containers provide support for building and testing Bro and the metron-bro-plugin-kafka using a number of Docker containers.
The use of these scripts and containers allow an easier, automated workflow for testing new features, fixes, or regressions than before.
One of the goals is for this to be extensible, such that new scripts can be introduced and run as well.  This will allow, for example, one or more
testing scripts to be added to a pull request, and subsequently to a test suite.


#### Directories

```bash
── containers 
│   └── bro-localbuild-container
├── in_docker_scripts
├── logs
└── scripts
```

- `containers` : the parent of all of the containers that this project defines.  We use several containers, not all of them ours
  - `bro-localbuild-container` : the docker container directory for our bro container, used for building bro, the librdkafka, and our plugin, as well as running bro
- `in_docker_scripts` : this directory is mapped to the bro docker container as /root/built_in_scripts.  These represent the library of scripts we provide to be run in the docker container.
- `logs` : a default log directory to use while running the scripts
- `scripts` : these are the scripts that are run on the host for creating the docker bits, running containers, running or executing commands against containers ( such as executing one of the built_in_scripts ), and cleaning up resources

