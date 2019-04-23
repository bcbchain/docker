#!/bin/bash

set -euo pipefail

uid=$(id -u)
if [[ "${uid:-}" != "0" ]]; then
  echo "must be root user"
  exit 1
fi

function osDetect {
  l=$(grep '^ID=.*centos' /etc/os-release | wc -l)
  if [[ "${l:-}" = "1" ]]; then
    v=$(grep '^VERSION_ID=.*7' /etc/os-release | wc -l)
    if [[ "${v:-}" = "1" ]]; then
      echo "centos7"
      return
    fi
  fi
  l=$(grep '^ID=ubuntu' /etc/os-release | wc -l)
  if [[ "${l:-}" = "1" ]]; then
    v=$(grep '^VERSION_ID=.*18.04' /etc/os-release | wc -l)
    if [[ "${v:-}" = "1" ]]; then
      echo "ubuntu18"
      return
    fi
  fi
  echo "need centos7 or ubuntu18.04"
}

osver=$(osDetect)
if [[ "${osver}" = "centos7" ]]; then
  tar xvf docker.allrpm.tar.gz && yum localinstall *.rpm  -y && rm -f *.rpm && systemctl enable docker && systemctl start docker
elif [[ "${osver}" = "ubuntu18" ]]; then
  tar xvf docker.io.alldeb.tar.gz && dpkg -i *.deb && rm -f *.deb && systemctl enable docker && systemctl start docker
else
  echo ${osver}
  exit 1
fi

if [ -f golang.alpine.tar.gz ]; then
  gzip -d golang.alpine.tar.gz
fi
if [ -f alpine.tar.gz ]; then
  gzip -d alpine.tar.gz
fi
if [ ! -f golang.alpine.tar ]; then
  echo "not found golang.alpine.tar"
  exit 1
fi
if [ ! -f alpine.tar ]; then
  echo "not found alpine.tar"
  exit 1
fi

if [[ "$?" = "0" ]]; then
  docker load -i golang.alpine.tar
  docker load -i alpine.tar
fi

if [[ "$?" = "0" ]]; then
  loaded=$(docker images | grep -E "^golang\s+alpine|^alpine\s+latest" | wc -l)
  if [[ "${loaded:-}" = "2" ]]; then
    echo "docker is ready!"
    exit 0
  fi
else
    echo "something wrong!"
    exit 1
fi
