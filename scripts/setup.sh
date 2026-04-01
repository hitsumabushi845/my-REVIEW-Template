#!/bin/bash

set -eux

apt-get update && apt-get install -y \
build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev python3-pip

bundle install
rm -rf node_modules
# --unsafe-perm はrootでの実行時(= docker環境)で必要 非root時の挙動に影響なし
npm install --unsafe-perm

pip install --break-system-packages pygments

VERSION="v4.52.5"
PLATFORM="linux_arm64"

wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_${PLATFORM}.tar.gz -O - | tar zxf - ./yq_${PLATFORM} && mv yq_${PLATFORM} /usr/local/bin/yq 
