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

# Load configuration
source "${SCRIPT_DIR}/config.sh"
IMAGE_NAME=${IMAGE_NAME:-"my-image"}

podman --version
if [ $? -ne 0 ]; then
	sudo apt update
	sudo apt install -y podman
fi

podman run -d "localhost/${IMAGE_NAME}:latest"
sleep 2
podman ps | grep "localhost/${IMAGE_NAME}:latest"
if [ $? -ne 0 ]; then
	echo "Failed to run ${IMAGE_NAME}"
	podman ps -a
	exit 1
fi

echo "Succeeded to run the container image."