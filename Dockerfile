FROM ubuntu:latest

## Base
## --
RUN apt-get update
RUN apt-get install -y --force-yes\
 unzip \
 curl \
 supervisor

COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 9001

## Consul
## --
## Dir Layout
ENV CONSUL_HOME /opt/consul
RUN mkdir -p ${CONSUL_HOME}/conf \
  && mkdir -p ${CONSUL_HOME}/data \
  && mkdir -p ${CONSUL_HOME}/logs \
  && mkdir -p ${CONSUL_HOME}/ui

## Binary
ENV CONSUL_VERSION 0.7.0
ENV CONSUL_SHA256 b350591af10d7d23514ebaa0565638539900cdb3aaa048f077217c4c46653dd8

RUN curl \
  --insecure \
  --location \
  https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_linux_amd64.zip \
  > /tmp/consul.zip

RUN echo "${CONSUL_SHA256}  /tmp/consul.zip" > /tmp/consul.sha256 \
 && sha256sum -c /tmp/consul.sha256 \
 && cd /bin \
 && unzip /tmp/consul.zip \
 && chmod +x /bin/consul \
 && rm /tmp/consul.zip

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

## Consul - UI
RUN curl \
  --insecure \
  --location \
  https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_web_ui.zip \
  > /tmp/webui.zip

RUN cd /tmp \
 && unzip webui.zip \
 && mv index.html ${CONSUL_HOME}/ui \
 && mv static ${CONSUL_HOME}/ui \
 && rm webui.zip

## Consul - Conf
COPY consul/* ${CONSUL_HOME}/conf/
COPY supervisor/conf.d/* /etc/supervisor/conf.d/


## Service
## --
CMD ["supervisord", "-n"]


