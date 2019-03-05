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
FROM centos:7
WORKDIR /root

# install development tools
RUN yum -y groupinstall "Development Tools" && \
   yum -y install cmake make gcc gcc-c++ \
   flex bison libpcap libpcap-devel \
   openssl-devel python-devel swig \
   zlib-devel perl \
   cyrus-sasl cyrus-sasl-devel cyrus-sasl-gssapi \
   git jq screen

# copy in the screen -rc
COPY .screenrc /root

# install bro
RUN curl -L https://www.bro.org/downloads/bro-2.5.5.tar.gz | tar xvz
WORKDIR bro-2.5.5/
RUN ./configure
RUN make
RUN make install
ENV PATH="${PATH}:/usr/local/bro/bin"
ENV PATH="${PATH}:/usr/bin"

# install pip
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install python-pip && \
    yum clean all && \
    pip install --upgrade pip && \
    pip install bro-pkg && \
    bro-pkg autoconfig

# install librdkafka
RUN curl -L https://github.com/edenhill/librdkafka/archive/v0.11.5.tar.gz | tar xvz
WORKDIR librdkafka-0.11.5/
RUN ./configure --enable-sasl
RUN make
RUN make install
WORKDIR /root
