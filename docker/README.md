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
├── containers
│   └── bro-localbuild-container
├── data
├── in_docker_scripts
├── scripts
└── test_output
```
- `containers`: The parent of all of the containers that this project defines.  We use several containers, not all of them ours.
  - `bro-localbuild-container`: The docker container directory for our bro container, used for building bro, the librdkafka, and our plugin, as well as running bro.
- `data`: The default path for pcap data to be used in tests.
- `in_docker_scripts`: This directory is mapped to the bro docker container as /root/built_in_scripts.  These represent the library of scripts we provide to be run in the docker container.
- `scripts`: These are the scripts that are run on the host for creating the docker bits, running containers, running or executing commands against containers ( such as executing one of the built_in_scripts ), and cleaning up resources.
- `test_output`: Directory where the bro logs and kafka logs per test/pcap are stored.


#### Scripts that execute _in_ the docker container

```bash
├── build_bro_plugin.sh
├── configure_bro_plugin.sh
├── process_data_file.sh
├── wait-for-it.sh
├── wait_for_kafka.sh
└── wait_for_zk.sh
```

- `build_bro_plugin.sh`: Runs `bro-pkg` to build and install the provided version of the plugin.
- `configure_bro_plugin.sh`: Configures the plugin for the kafka container, and routes all traffic types.
- `process_data_file.sh`: Runs `bro -r` on the passed file
- `wait-for-it.sh`: Waits for a port to be open, so we know something is available.
- `wait_for_kafka.sh`: Waits for the kafka to be available.
- `wait_for_zk.sh`: Waits for zookeeper to be available.


#### Scripts executed on the host to setup and interact with the docker containers

```bash
├── analyze_results.sh
├── build_container.sh
├── cleanup_docker.sh
├── create_docker_network.sh
├── destroy_docker_network.sh
├── docker_execute_build_bro_plugin.sh
├── docker_execute_configure_bro_plugin.sh
├── docker_execute_process_data_file.sh
├── docker_execute_shell.sh
├── docker_run_bro_container.sh
├── docker_run_consume_kafka.sh
├── docker_run_create_topic_in_kafka.sh
├── docker_run_get_offset_kafka.sh
├── docker_run_kafka_container.sh
├── docker_run_wait_for_kafka.sh
├── docker_run_wait_for_zookeeper.sh
├── docker_run_zookeeper_container.sh
├── download_sample_pcaps.sh
├── print_results.sh
├── split_kakfa_output_by_log.sh
└── stop_container.sh
```

- `analyze_results.sh`: Analyzes the `results.csv` files for any issues
  ###### Parameters
  ```bash
  --test-directory               [REQUIRED] The directory for the tests
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
  --container-name                [OPTIONAL] The Docker container name. Default: bro
  --network-name                  [OPTIONAL] The Docker network name. Default: bro-network
  ```
- `create_docker_network.sh`: Creates the Docker network that the containers will use
  ###### Parameters
  ```bash
  --network-name                  [OPTIONAL] The Docker network name. Default: bro-network
  ```
- `destroy_docker_network.sh`: Destroys a Docker network by calling `docker network rm`
  ###### Parameters
  ```bash
   --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  ```
- `docker_execute_build_bro_plugin.sh`: Executes `build_bro_plugin.sh` in the bro container
  ###### Parameters
  ```bash
   --container-name               [OPTIONAL] The Docker container name. Default: bro
  ```
- `docker_execute_configure_bro_plugin.sh`: Executes `configure_bro_plugin.sh` in the bro container
  ###### Parameters
  ```bash
  --container-name                [OPTIONAL] The Docker container name. Default: bro
  ```
- `docker_execute_process_data_dir.sh`: Executes `process_data_dir.sh` in the bro container
  ###### Parameters
   ```bash
   --container-name               [OPTIONAL] The Docker container name. Default: bro
   ```
- `docker_execute_shell.sh`: `docker execute -i -t bash` to get a shell in a given container
  ###### Parameters
  ```bash
  --container-name                [OPTIONAL] The Docker container name. Default: bro
  ```
- `docker_run_bro_container.sh`:  Runs the bro docker container in the background
  ###### Parameters
  ```bash
  --container-name                [OPTIONAL] The Docker container name. Default: bro
  --network-name                  [OPTIONAL] The Docker network name. Default: bro-network
  --scripts-path                  [OPTIONAL] The path with the scripts you may run in the container. These are your scripts, not the built in scripts
  --data-path                     [OPTIONAL] The name of the directory to map to /root/data in the container
  --docker-parameter              [OPTIONAL, MULTIPLE] Each parameter with this name will be passed to docker run
  ```
  
  > NOTE about `--scripts-path`
  > The scripts path provided with be mapped into the bro container at `/root/scripts`.  This allows you to _inject_ your own scripts (not managed as part of this source project) into the container.
  > You can then execute these scripts or use them together as part of testing etc. by creating `docker execute` scripts like those here.
  > The goal is to allow an individual to use and maintain their own library of scripts to use instead of, or in concert with the scripts maintained by this project.
  
- `docker_run_consume_kafka.sh`: Runs an instance of the kafka container, with the console consumer `kafka-console-consumer.sh --topic $KAFKA_TOPIC --offset $OFFSET --partition 0 --bootstrap-server kafka:9092`
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  --offset                       [OPTIONAL] The kafka offset. Default: 0
  --kafka-topic                  [OPTIONAL] The kafka topic to consume from. Default: bro
  ```
- `docker_run_get_offset_kafka.sh`: Runs an instance of the kafka container and gets the current offset for the specified topic
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  --kafka-topic                  [OPTIONAL] The kafka topic to get the offset from. Default: bro
  ```
- `docker_run_create_topic_in_kafka.sh`: Runs an instance of the kafka container, creating the specified topic
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  --kafka-topic                  [OPTIONAL] The kafka topic to create. Default: bro
  ```
- `docker_run_kafka_container.sh`: Runs the main instance of the kafka container in the background
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  ```
- `docker_run_wait_for_kafka.sh`: Runs the `wait_for_kafka.sh` in a base centos container
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  ```
- `docker_run_wait_for_zookeeper.sh`: Runs the `wait_for_zk.sh` in a base centos container
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  ```
- `docker_run_zookeeper_container.sh`: Runs the zookeeper container in the background
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: bro-network
  ```
- `download_sample_pcaps.sh`: Downloads the sample pcaps to a specified directory. If they exist, it is a no-op
  
   > The sample pcaps are:
   >  -  https://github.com/bro/try-bro/blob/master/manager/static/pcaps/exercise_traffic.pcap
   >  -  http://downloads.digitalcorpora.org/corpora/network-packet-dumps/2008-nitroba/nitroba.pcap 
   >  -  https://github.com/bro/try-bro/raw/master/manager/static/pcaps/ssh.pcap
   >  -  https://github.com/markofu/pcaps/blob/master/PracticalPacketAnalysis/ppa-capture-files/ftp.pcap?raw=true 
   >  -  https://github.com/EmpowerSecurityAcademy/wireshark/blob/master/radius_localhost.pcapng?raw=true 
   >  -  https://github.com/kholia/my-pcaps/blob/master/VNC/07-vnc

  ###### Parameters
  ```bash
  --data-path                    [REQUIRED] The pcap data path
  ```
- `print_results.sh`: Prints the `results.csv` for all the pcaps processed in the given directory to console
  ###### Parameters
  ```bash
  --test-directory               [REQUIRED] The directory for the tests
  ```
- `split_kafka_output_by_log.sh`: For a pcap result directory, will create a LOG.kafka.log for each LOG.log's entry in the kafka-output.log
  ###### Parameters
  ```bash
  --log-directory                [REQUIRED] The directory with the logs
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
6. Creates the specified topic
7. Downloads sample PCAP data
8. Runs the bro container in the background

> Note that all parameters passed to this script are passed to the `docker_run_bro_container.sh` script

9. Builds the bro plugin
10. Configures the bro plugin
11. Runs bro against all the pcap data, one at a time
12. Executes a kafka client to read the data from bro for each pcap file
13. Stores the output kafka messages and the bro logs into the test_output directory

```bash
>tree Tue_Jan__8_21_54_10_EST_2019
Tue_Jan__8_21_54_10_EST_2019
├── exercise-traffic_pcap
│   ├── capture_loss.log
│   ├── conn.log
│   ├── dhcp.log
│   ├── dns.log
│   ├── files.log
│   ├── http.log
│   ├── kafka-output.log
│   ├── known_certs.log
│   ├── known_devices.log
│   ├── loaded_scripts.log
│   ├── notice.log
│   ├── packet_filter.log
│   ├── reporter.log
│   ├── smtp.log
│   ├── software.log
│   ├── ssl.log
│   ├── stats.log
│   ├── weird.log
│   └── x509.log
├── ftp_pcap
│   ├── capture_loss.log
│   ├── conn.log
│   ├── files.log
│   ├── ftp.log
│   ├── kafka-output.log
│   ├── loaded_scripts.log
│   ├── packet_filter.log
│   ├── reporter.log
│   ├── software.log
│   └── stats.log
```

14. Creates a results.csv for each pcap that has the line counts of the kafka and the bro output for each log
15. Prints all the results.csv to the screen

As we can see, the output is a folder named for the test run time, with a sub folder per pcap, containing all the bro logs and the kafka_output.log.


At this point the containers are up and running in the background.

Other scripts may then be used to do your testing, for example running:
```bash
./scripts/docker_execute_shell.sh
```

> NOTE: If the scripts are run repeatedly, and there is no change in bro or the librdkafka, the line `./run_end_to_end.sh` can be replaced by `./run_end_to_end.sh --skip-docker-build`, which uses the `--skip-docker-build` flag to not rebuild the bro container, saving the time of rebuilding bro and librdkafka.

> NOTE: After you are done, you must call the `finish_end_to_end.sh` script to cleanup.


##### `run_end_to_end.sh`
###### Parameters
```bash
--skip-docker-build             [OPTIONAL] Skip build of bro docker machine.
--no-pcaps                      [OPTIONAL] Do not run pcaps.
--data-path                     [OPTIONAL] The pcap data path. Default: ./data
--kafka-topic                   [OPTIONAL] The kafka topic name to use. Default: bro
--plugin-version                [OPTIONAL] The plugin version. Default: the current branch name
```

> NOTE: The provided `--plugin-version` is passed to the [`bro-pkg install`](https://docs.zeek.org/projects/package-manager/en/stable/bro-pkg.html#install-command) command within the container, which allows you to specify a version tag, branch name, or commit hash.  However, that tag, branch, or commit *must* be available in the currently checked out plugin repository.

