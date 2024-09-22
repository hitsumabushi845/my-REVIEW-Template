#!/bin/bash -xe

set -eux
npm ci
bundle install
rm -rf node_modules
# --unsafe-perm はrootでの実行時(= docker環境)で必要 非root時の挙動に影響なし
npm install --unsafe-perm

# install python3
apt-get update -y
apt-get install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y
apt-get install python3 -y
apt-get install python3-pip -y
pip install --break-system-packages pygments

# install yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
chmod +x /usr/bin/yq
