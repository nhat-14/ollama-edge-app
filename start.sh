#!/bin/bash
set -e

echo "Waiting for Ollama to be online..."

until curl -s http://ollama:11434/api/tags > /dev/null; do
    sleep 1
done

echo "Ollama is ready"

echo "Pulling TinyLlama model..."

curl -f -X POST http://ollama:11434/api/pull \
    -H "Content-Type: application/json" \
    -d '{"name":"tinyllama","stream":false}'

echo "Waiting for TinyLlama to be available..."

until curl -sf http://ollama:11434/api/show \
    -H "Content-Type: application/json" \
    -d '{"name":"tinyllama"}' > /dev/null; do
    sleep 2
done

echo "TinyLlama is ready"

echo "Starting edge application..."

exec python3 /usr/src/app/main.py