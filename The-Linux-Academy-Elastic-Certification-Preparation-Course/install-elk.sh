#!/bin/bash

function configure {
  # Check root start
  if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root"
     exit 1
  fi
  # Create elastic user
  useradd elastic
  # Configure nodes
  echo "elastic - nproc 4096" >> /etc/security/limits.conf
  echo "elastic - nofile 65536" >> /etc/security/limits.conf
  echo "vm.max_map_count=262144" >> /etc/sysctl.conf
  # Use elastic the user
  sysctl -p
  sudo su - elastic
}
### all nodes

  function elastic {
      #statements

    VERSION=7.2.1-linux-x86_64
    curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION.tar.gz
    tar -xzvf elasticsearch-$VERSION.tar.gz
    rm elasticsearch-$VERSION.tar.gz
    mv elasticsearch-7.2.1 elasticsearch
  }

function kibana {

  VERSION=7.2.1-linux-x86_64
  curl -O https://artifacts.elastic.co/downloads/kibana/kibana-$VERSION.tar.gz
  tar -xzvf kibana-$VERSION.tar.gz
  rm kibana-$VERSION.tar.gz
  mv kibana-$VERSION kibana
}
