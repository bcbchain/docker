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
  yum update -y && yum install epel-release -y && yum install docker -y && systemctl start docker
elif [[ "${osver}" = "ubuntu18" ]]; then
  apt update && apt upgrade -y && apt install docker.io -y && systemctl start docker
else
  echo ${osver}
  exit 1
fi
if [[ "$?" = "0" ]]; then
  docker pull golang:apline
  docker pull alpine
fi

if [[ "$?" = "0" ]]; then
  loaded=$(docker images | grep -E "^golang\s+alpine|^alpine\s+latest" | wc -l)
  if [[ "${loaded:-0}" = "2" ]]; then
    echo "docker is ready!"
    exit 0
  fi
else
    echo "something wrong!"
    exit 1
fi
