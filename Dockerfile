FROM python:3.12-slim

WORKDIR /usr/src/app

COPY main.py .

RUN apt-get update && \
    apt-get install -y curl && \
    pip install --no-cache-dir ollama && \
    rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1

COPY ./start.sh /start.sh
COPY ./application-description/resources/LICENSE /LICENSE
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]