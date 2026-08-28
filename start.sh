#!/bin/bash
set -e

echo "Waiting for Ollama..."

until curl -s http://ollama:11434/api/tags > /dev/null; do
    sleep 1
done

echo "Ollama is ready"

echo "Starting edge application..."

exec python3 /usr/src/app/main.py