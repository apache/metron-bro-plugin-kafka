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
ARG ZEEK_VERSION
ARG LIBRDKAFKA_VERSION

# install development tools
RUN yum -y groupinstall "Development Tools" && \
   yum -y install cmake make gcc gcc-c++ \
   flex bison libpcap libpcap-devel \
   openssl-devel python-devel swig \
   zlib-devel perl \
   cyrus-sasl cyrus-sasl-devel cyrus-sasl-gssapi \
   git jq screen tree vim

# copy in the .screenrc
COPY .screenrc /root

# install zeek
WORKDIR /root
RUN git clone https://github.com/zeek/zeek
WORKDIR zeek/
RUN git checkout "v${ZEEK_VERSION}"
RUN git submodule update --init --recursive
RUN ./configure
RUN make
RUN make install
ENV PATH="${PATH}:/usr/local/zeek/bin"
ENV PATH="${PATH}:/usr/bin"

# install pip3 and zkg
WORKDIR /root
COPY requirements.txt requirements.txt
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install python3-pip && \
    yum clean all && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install -r requirements.txt && \
    zkg autoconfig

# install librdkafka
WORKDIR /root
RUN curl -L "https://github.com/edenhill/librdkafka/archive/v${LIBRDKAFKA_VERSION}.tar.gz" | tar xvz
WORKDIR "librdkafka-${LIBRDKAFKA_VERSION}/"
RUN ./configure --enable-sasl
RUN make
RUN make install
