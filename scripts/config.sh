#!/bin/bash
#
# Copyright (c) 2026 Duc Nhat Luong
#
# Licensed under the MIT License.
# See the LICENSE file in this repository for details.

# Global configuration
REGISTRY="ghcr.io"
IMAGE_NAME=ollama-edge-app
IMAGE_TAG="develop"
MULTI_ARCH_BUILD="false"

REGISTRY_TOKEN_NAME="nhat-14"
# REGISTRY_TOKEN_PASSWD="" # GitHub PAT for the ghcr.io registry


# Application package name: "<app-name>-app-package"
APP_PACKAGE_NAME="ollama-edge-app-package" 

# # Paths
# PROJECT_ROOT="/home/azureuser/workspace/my-project"
# CONFIG_DIR="${PROJECT_ROOT}/config"