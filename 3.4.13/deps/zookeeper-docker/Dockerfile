FROM zookeeper:3.4.13

ENV ZOO_LOG_DIR=/logs

RUN set -ex; \
    mkdir -p "$ZOO_LOG_DIR"; \
    chown "$ZOO_USER:$ZOO_USER" "$ZOO_LOG_DIR"

VOLUME [ "$ZOO_LOG_DIR" ]
