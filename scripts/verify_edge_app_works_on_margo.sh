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
IMAGE_TAG=${IMAGE_TAG:-"develop"}
APP_PACKAGE_NAME=${APP_PACKAGE_NAME:-"ollama-edge-app-package"}

# HELM_IMAGE="edge-app-chart:1.0.0"

podman --version
if [ $? -ne 0 ]; then
	sudo apt update
	sudo apt install -y podman
fi

echo "Pushing container image to harbor.."
set -ex
docker pull ghcr.io/nhat-14/${IMAGE_NAME}:${IMAGE_TAG}
docker tag ghcr.io/nhat-14/${IMAGE_NAME}:${IMAGE_TAG} harbor.machine:8443/library/"${IMAGE_NAME}:${IMAGE_TAG}"
docker login harbor.machine:8443 -u admin -p Harbor12345
docker push harbor.machine:8443/library/"${IMAGE_NAME}:${IMAGE_TAG}"
set +x

# echo "Pushing helm chart to harbor.."
# set -x
# cd ../plugfest202607/apps/edge-app/helm-chart/
# helm package .
# helm push edge-app-chart-1.0.0.tgz oci://harbor.machine:8443/library
# set +x
# cd ~-

echo "Pushing application package to harbor.."
set -x
echo "Harbor12345" | oras login harbor.machine:8443   -u admin --password-stdin
cd application-description/

files=("margo.yaml:application/vnd.margo.app.description.v1+yaml")

if [ -d "resources" ] && [ "$(ls -A resources 2>/dev/null)" ]; then
while IFS= read -r file; do
	if [ -f "$file" ]; then
	files+=("$file:application/octet-stream")
	fi
done < <(find resources -type f 2>/dev/null)
fi

oras push harbor.machine:8443/library/"${APP_PACKAGE_NAME}:latest" \
  --artifact-type "application/vnd.margo.app.v1+json" \
  --insecure \
  "${files[@]}"

set +ex
cd ~-

cd "$HOME/workspace/sandbox/scripts"

echo "Uploading application package.."
sudo -E bash wfm-cli.sh upload-app-non-interactive "${APP_PACKAGE_NAME}"
if [ $? -ne 0 ]; then
	echo "Failed to upload application package for ${APP_PACKAGE_NAME}."
	exit 1
fi

echo "Checking application packages.."
sudo -E bash wfm-cli.sh list-packages | grep ONBOARD
if [ $? -ne 0 ]; then
	echo "Failed to get any ONBOARDED application packages."
	exit 1
fi

PACKAGE_ID=$(sudo -E bash wfm-cli.sh list-packages | grep ONBOARD | awk -F'|' '{print $2}' | sed s/" "//g)
if [ -z "${PACKAGE_ID}" ]; then
	echo "Failed to get PACKAGE_ID."
	sudo -E bash wfm-cli.sh list-packages | grep ONBOARD
	exit 1
fi

# K3S_DEVICE_ID=$(sudo -E bash wfm-cli.sh list-devices | grep ONBOARD | grep 'Standalone Cluster' | awk -F'|' '{print $2}' | sed s/" "//g)
# if [ -z "${K3S_DEVICE_ID}" ]; then
# 	echo "Failed to get K3S_DEVICE_ID."
# 	sudo -E bash wfm-cli.sh list-devices
# 	exit 1
# fi

DOCKER_DEVICE_ID=$(sudo -E bash wfm-cli.sh list-devices | grep ONBOARD | grep 'compose' | awk -F'|' '{print $2}' | sed s/" "//g)
if [ -z "${DOCKER_DEVICE_ID}" ]; then
	echo "Failed to get DOCKER_DEVICE_ID."
	sudo -E bash wfm-cli.sh list-devices
	exit 1
fi

# echo "K3S_DEVICE_ID   : ${K3S_DEVICE_ID}"
echo "DOCKER_DEVICE_ID: ${DOCKER_DEVICE_ID}"

DEVICE_ID=${DOCKER_DEVICE_ID}

# to make it stable
sleep 10

echo "Deploying application on edge.."
sudo -E bash wfm-cli.sh deploy-non-interactive "${PACKAGE_ID}" "${DEVICE_ID}"
if [ $? -ne 0 ]; then
	echo "Failed to deploy application on edge."
	exit 1
fi

# to make it stable
sleep 10

echo "Logs of symphony-api-container ----------------------------------------------------------"
sudo docker logs symphony-api-container

sleep 10

echo "Checking deployment.."
sudo -E bash wfm-cli.sh list-deployments

cd ~-

echo "Succeeded to run this script."