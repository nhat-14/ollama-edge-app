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

MULTI_ARCH_BUILD=${MULTI_ARCH_BUILD:-"false"}

rm -rf $(find . -name __pycache__)

podman --version
if [ $? -ne 0 ]; then
	sudo apt update
	sudo apt install -y podman
fi

set +e
podman rmi --force ${IMAGE_NAME}
set -e

if [ "${MULTI_ARCH_BUILD}" == "false" ]; then
	podman build -t ${IMAGE_NAME} .
else
	sudo podman run --rm --privileged docker.io/multiarch/qemu-user-static --reset -p yes
	podman build --platform linux/amd64,linux/arm64 --format docker -t ${IMAGE_NAME} .
fi

set +x
echo "Succeeded to build the container image."