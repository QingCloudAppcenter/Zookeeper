FROM dockerhub.qingcloud.com/qingcloud/zookeeper:3.4.13

ENV ZOO_REST_HOME=/zookeeper-3.4.13/contrib/rest

RUN set -ex; \
    mv $ZOO_REST_HOME/conf/* $ZOO_CONF_DIR; \
    mv zookeeper-*.jar $ZOO_REST_HOME

EXPOSE 9998/tcp
VOLUME ["$ZOO_CONF_DIR", "$ZOO_LOG_DIR"]

COPY bin/zkRest.sh $ZOO_REST_HOME
ENV PATH=$PATH:$ZOO_REST_HOME

WORKDIR $ZOO_REST_HOME

ENTRYPOINT ["zkRest.sh"]
CMD ["start-foreground"]
