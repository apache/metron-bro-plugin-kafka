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


#### Scripts that execute _in_ the docker container

```bash
├── build_bro_plugin.sh
├── configure_bro_plugin.sh
├── process_data_dir.sh
├── wait-for-it.sh
├── wait_for_kafka.sh
└── wait_for_zk.sh
```

- `build_bro_plugin.sh`: Runs `bro-package` to build and install the plugin.  
- `configure_bro_plugin.sh`: Configures the plugin for the kafka container, and routes all traffic types.
- `process_data_dir.sh`: Runs `bro -r` for each file in the `/root/data` directory and sub-directories.
- `wait-for-it.sh`: Waits for a port to be open, so we know something is available.
- `wait_for_kafka.sh`: Waits for the kafka to be available.
- `wait_for_zk.sh`: Waits for zookeeper to be available.


#### Scripts executed on the host to setup and interact with the docker containers

```bash
├── build_container.sh
├── cleanup_containers.sh
├── create_docker_network.sh
├── destroy_docker_network.sh
├── docker_execute_build_bro_plugin.sh
├── docker_execute_configure_bro_plugin.sh
├── docker_execute_process_data_dir.sh
├── docker_execute_shell.sh
├── docker_run_bro_container.sh
├── docker_run_consume_bro_kafka.sh
├── docker_run_create_bro_topic_in_kafka.sh
├── docker_run_kafka_container.sh
├── docker_run_wait_for_kafka.sh
├── docker_run_wait_for_zookeeper.sh
├── docker_run_zookeeper_container.sh
├── download_sample_pcaps.sh
└── stop_container.sh
```

- `build_container.sh`: Runs docker build in the passed directory, and names the results
  ###### Parameters
  ```bash
   --container-directory          [REQUIRED] The directory with the Dockerfile
   --container-name               [REQUIRED] The name to give the Docker container
  ```
- `cleanup_containers.sh`: Stops the containers and destroys the network 
  ###### Parameters
  ```bash
  --container-name                [OPTIONAL] The Docker container name. Default bro
  --network-name                  [OPTIONAL] The Docker network name. Default bro-network
  ```
- `create_docker_network.sh`: Creates the Docker network that the containers will use
  ###### Parameters
  ```bash
  --network-name                  [OPTIONAL] The Docker network name. Default bro-network
  ```
- `destroy_docker_network.sh`: Destroys a Docker network by calling `docker network rm`
  ###### Parameters
  ```bash
   --network-name                 [OPTIONAL] The Docker network name. Default bro-network
  ```
- `docker_execute_build_bro_plugin.sh`: Executes `build_bro_plugin.sh` in the bro container
  ###### Parameters
  ```bash
   --container-name               [OPTIONAL] The Docker container name. Default bro
  ```
- `docker_execute_configure_bro_plugin.sh`: Executes `configure_bro_plugin.sh` in the bro container
  ###### Parameters
  ```bash
  --container-name                [OPTIONAL] The Docker container name. Default bro
  ```
- `docker_execute_process_data_dir.sh`: Executes `process_data_dir.sh` in the bro container
  ###### Parameters
   ```bash
   --container-name               [OPTIONAL] The Docker container name. Default bro
   ```
- `docker_execute_shell.sh`: `docker execute -i -t bash` to get a shell in a given container
  ###### Parameters
  ```bash
  --container-name                [OPTIONAL] The Docker container name. Default bro
  ```
- `docker_run_bro_container.sh`:  Runs the bro docker container in the background
  ###### Parameters
  ```bash
  --container-name                [OPTIONAL] The name to give the container. Default bro
  --network-name                  [OPTIONAL] The Docker network name. Default bro-network
  --scripts-path                  [OPTIONAL] The path with the scripts you may run in the container. These are your scripts, not the built in scripts
  --data-path                     [OPTIONAL] The name of the directory to map to /root/data
  --log-path                      [REQUIRED] The path to log to
  --docker-parameter              [OPTIONAL, MULTIPLE] Each parameter with this name will be passed to docker run
  ```
  
  > NOTE about --scripts-path
  > The scripts path provided with be mapped into the bro container at `/root/scripts`.  This allows you to _inject_ your own scripts (not managed as part of this source project) into the container.
  > You can then execute these scripts or use them together as part of testing etc. by creating `docker execute` scripts like those here.
  > The goal is to allow an individual to use and maintain their own library of scripts to use instead of, or in concert with the scripts maintained by this project.
  
- `docker_run_consume_bro_kafka.sh`: Runs an instance of the kafka container, with the console consumer `kafka-console-consumer.sh --topic bro --from-beginning --bootstrap-server kafka:9092`
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default bro-network
  ```
- `docker_run_create_bro_topic_in_kafka.sh`: Runs an instance of the kafka container, creating the `bro` topic
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default bro-network
  ```
- `docker_run_kafka_container.sh`: Runs the main instance of the kafka container in the background
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default bro-network
  ```
- `docker_run_wait_for_kafka.sh`: Runs the `wait_for_kafka.sh` in a base centos container
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default bro-network
  ```
- `docker_run_wait_for_zookeeper.sh`: Runs the `wait_for_zk.sh` in a base centos container
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default bro-network
  ```
- `docker_run_zookeeper_container.sh`: Runs the zookeeper container in the background
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default bro-network
  ```
- `download_sample_pcaps.sh`: Downloads the sample pcaps to a specified directory. If they exist, it is a no-op
  
   > The sample pcaps are:
   >  -  https://www.bro.org/static/traces/exercise-traffic.pcap 
   >  -  http://downloads.digitalcorpora.org/corpora/network-packet-dumps/2008-nitroba/nitroba.pcap 
   >  -  https://www.bro.org/static/traces/ssh.pcap 
   >  -  https://github.com/markofu/pcaps/blob/master/PracticalPacketAnalysis/ppa-capture-files/ftp.pcap?raw=true 
   >  -  https://github.com/EmpowerSecurityAcademy/wireshark/blob/master/radius_localhost.pcapng?raw=true 
   >  -  https://github.com/kholia/my-pcaps/blob/master/VNC/07-vnc

  ###### Parameters
  ```bash
  --data-path                    [REQURIED] The pcap data path
  ```
- `stop_container.sh`: Stops and removes a Docker container with a given name
  ###### Parameters
  ```bash
  --container-name               [REQUIRED] The Docker container name
  ```

#### The example end to end test script

`run_end_to_end.sh` is provided as an example of a testing script.  Specific or extended scripts can be created similar to this script to use the containers.
This script does the following:

1. Creates the Docker network
2. Runs the zookeeper container
3. Waits for zookeeper to be available
4. Runs the kafka container
5. Waits for kafka to be available
6. Creates the bro topic
7. Downloads sample PCAP data
8. Runs the bro container in the background

> Note that all parameters passed to this script are passed to the `docker_run_bro_container.sh` script

9. Builds the bro plugin
10. Configures the bro plugin
11. Runs bro against all the pcap data
12. Executes a kafka client to read the data from bro

At this point the containers are up and running in the background.

Other scripts may then be used to do your testing, for example running 
```bash
./scripts/docker_execute_shell.sh
```

> NOTE: If the scripts are run repeatedly, and there is no change in bro or the librdkafka, the line `./run_end_to_end.sh ` can be replaced by `./example_script.sh --skip-docker-build `, which uses the `--skip-docker-build` flag to not rebuild the bro container and building the bro and librdkafka code

> NOTE: After you are done, you must call the finish_end_to_end.sh script to cleanup


`run_end_to_end.sh`
###### Parameters
```bash
--skip-docker-build             Skip build of bro docker machine
--data-path                    [OPTIONAL] The pcap data path, defaults to ./data
```