#!/bin/bash
#
# Copyright (c) 2026 Duc Nhat Luong
#
# This file is based on and adapted from:
# https://github.com/oomichi-melco/try-margo
#
# Original work:
# Copyright (c) 2026 Kenichi Omichi
#
# Licensed under the MIT License.
# See the LICENSE file in this repository for details.

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

docker compose version
if [ $? -ne 0 ]; then
	sudo apt update
	sudo apt install -y ca-certificates curl gnupg
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
	sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	docker compose version
fi

sudo usermod -aG docker $USER

echo "Running docker compose.."
docker compose up -d
sleep 10

echo "Checking container status.."
docker ps | grep Up
if [ $? -ne 0 ]; then
	echo "Failed to get valid status container."
	docker ps -a
	docker logs melcoedgeapp
	exit 1
fi

echo "Succeeded to run this script."