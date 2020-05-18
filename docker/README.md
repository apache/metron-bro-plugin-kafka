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

These scripts and containers provide support for building and testing Zeek and the metron-bro-plugin-kafka using a number of Docker containers.
The use of these scripts and containers allow an easier, automated workflow for testing new features, fixes, or regressions than before.
One of the goals is for this to be extensible, such that new scripts can be introduced and run as well.  This will allow, for example, one or more
testing scripts to be added to a pull request, and subsequently to a test suite.


#### Directories

```bash
├── containers
│   └── zeek
│   └── kafka
│   └── zookeeper
├── data
├── in_docker_scripts
├── scripts
└── test_output
```
- `containers`: The parent of all of the containers that this project defines.  We use several containers, not all of them ours.
  - `zeek`: The directory for our zeek container, used for building zeek, the librdkafka, and our plugin, as well as running zeek.
  - `kafka`: The directory for our kafka container.
  - `zookeeper`: The directory for our zookeeper container.
- `data`: The default path for pcap data to be used in tests.
- `in_docker_scripts`: This directory is mapped to the zeek docker container as /root/built_in_scripts.  These represent the library of scripts we provide to be run in the docker container.
- `scripts`: These are the scripts that are run on the host for creating the docker bits, running containers, running or executing commands against containers ( such as executing one of the built_in_scripts ), and cleaning up resources.
- `test_output`: Directory where the zeek logs and kafka logs per test/pcap are stored.


#### Scripts that execute _in_ the docker container

```bash
├── build_plugin.sh
├── configure_plugin.sh
├── process_data_file.sh
```

- `build_plugin.sh`: Runs `zkg` to build and install the provided version of the plugin.
- `configure_plugin.sh`: Configures the plugin for the kafka container, and routes all traffic types.
  ###### Parameters
  ```bash
  --kafka-topic                  [OPTIONAL] The kafka topic to configure. Default: zeek"
  ```
- `process_data_file.sh`: Runs `zeek -r` on the passed file


#### Scripts executed on the host to setup and interact with the docker containers

```bash
├── analyze_results.sh
├── docker_execute_build_plugin.sh
├── docker_execute_configure_plugin.sh
├── docker_execute_create_topic_in_kafka.sh
├── docker_execute_process_data_file.sh
├── docker_execute_shell.sh
├── docker_run_consume_kafka.sh
├── docker_run_get_offset_kafka.sh
├── download_sample_pcaps.sh
├── print_results.sh
├── split_kakfa_output_by_log.sh
```

- `analyze_results.sh`: Analyzes the `results.csv` files for any issues
  ###### Parameters
  ```bash
  --test-directory               [REQUIRED] The directory for the tests
  ```
- `docker_execute_build_plugin.sh`: Executes `build_plugin.sh` in the zeek container
  ###### Parameters
  ```bash
   --container-name              [OPTIONAL] The Docker container name. Default: metron-bro-plugin-kafka_zeek_1
  ```
- `docker_execute_configure_plugin.sh`: Executes `configure_plugin.sh` in the zeek container
  ###### Parameters
  ```bash
  --container-name               [OPTIONAL] The Docker container name. Default: metron-bro-plugin-kafka_zeek_1
  ```
- `docker_execute_create_topic_in_kafka.sh`: Creates the specified kafka topic in the kafka container
  ###### Parameters
  ```bash
  --container-name               [OPTIONAL] The Docker container name. Default: metron-bro-plugin-kafka_kafka-1_1
  --kafka-topic                  [OPTIONAL] The kafka topic to create. Default: zeek
  --partitions                   [OPTIONAL] The number of kafka partitions to create. Default: 2
  ```
- `docker_execute_process_data_file.sh`: Executes `process_data_file.sh` in the zeek container
  ###### Parameters
   ```bash
   --container-name              [OPTIONAL] The Docker container name. Default: metron-bro-plugin-kafka_zeek_1
   ```
- `docker_execute_shell.sh`: `docker execute -i -t bash` to get a shell in a given container
  ###### Parameters
  ```bash
  --container-name               [OPTIONAL] The Docker container name. Default: metron-bro-plugin-kafka_zeek_1
  ```
- `docker_run_consume_kafka.sh`: Runs an instance of the kafka container, with the console consumer `kafka-console-consumer.sh --topic $KAFKA_TOPIC --offset $OFFSET --partition $PARTITION --bootstrap-server kafka-1:9092`
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: metron-bro-plugin-kafka_default
  --offset                       [OPTIONAL] The kafka offset to read from. Default: 0
  --partition                    [OPTIONAL] The kafka partition to read from. Default: 0
  --kafka-topic                  [OPTIONAL] The kafka topic to consume from. Default: zeek
  ```
- `docker_run_get_offset_kafka.sh`: Runs an instance of the kafka container and gets the current offset for the specified topic
  ###### Parameters
  ```bash
  --network-name                 [OPTIONAL] The Docker network name. Default: metron-bro-plugin-kafka_default
  --kafka-topic                  [OPTIONAL] The kafka topic to get the offset from. Default: zeek
  ```
- `download_sample_pcaps.sh`: Downloads the sample pcaps to a specified directory. If they exist, it is a no-op
  
   > The sample pcaps are:
   >  -  https://github.com/zeek/try-zeek/blob/master/manager/static/pcaps/exercise_traffic.pcap
   >  -  http://downloads.digitalcorpora.org/corpora/network-packet-dumps/2008-nitroba/nitroba.pcap 
   >  -  https://github.com/zeek/try-zeek/raw/master/manager/static/pcaps/ssh.pcap
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

#### The example end to end test script

`run_end_to_end.sh` is provided as an example of a testing script.  Specific or extended scripts can be created similar to this script to use the containers.
This script does the following:

1. Runs docker compose
1. Creates the specified topic with the specified number of partitions
1. Downloads sample PCAP data
1. Runs the zeek container in the background
1. Builds the zeek plugin
1. Configures the zeek plugin
1. Runs zeek against all the pcap data, one at a time
1. Executes a kafka client to read the data from zeek for each pcap file
1. Stores the output kafka messages and the zeek logs into the test_output directory
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
1. Creates a results.csv for each pcap that has the line counts of the kafka and the zeek output for each log
1. Prints all the results.csv to the screen

As we can see, the output is a folder named for the test run time, with a sub folder per pcap, containing all the zeek logs and the `kafka_output.log`.


At this point the containers are up and running in the background.

Other scripts may then be used to do your testing, for example running:
```bash
./scripts/docker_execute_shell.sh
```

> NOTE: If the scripts are run repeatedly, and there is no change in zeek or the librdkafka, the line `./run_end_to_end.sh` can be replaced by `./run_end_to_end.sh --skip-docker-build`, which uses the `--skip-docker-build` flag to not rebuild the containers, saving the significant time of rebuilding zeek and librdkafka.

> NOTE: After you are done, you must call the `finish_end_to_end.sh` script to cleanup.


##### `run_end_to_end.sh`
###### Parameters
```bash
--skip-docker-build             [OPTIONAL] Skip build of zeek docker machine.
--no-pcaps                      [OPTIONAL] Do not run pcaps.
--data-path                     [OPTIONAL] The pcap data path. Default: ./data
--kafka-topic                   [OPTIONAL] The kafka topic name to use. Default: zeek
--partitions                    [OPTIONAL] The number of kafka partitions to create. Default: 2
--plugin-version                [OPTIONAL] The plugin version. Default: the current branch name
```

> NOTE: The provided `--plugin-version` is passed to the [`zkg install`](https://docs.zeek.org/projects/package-manager/en/stable/zeek-pkg.html#install-command) command within the container, which allows you to specify a version tag, branch name, or commit hash.  However, that tag, branch, or commit *must* be available in the currently checked out plugin repository.

