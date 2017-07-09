FROM centos:centos6

MAINTAINER Lukassos <lukassos@gmail.com>

# openssl - should be installed though
RUN yum -y install openssl

# Generate SSL certs into "/tmp/crypto_gen/ssl"
RUN mkdir -p /tmp/crypto_gen/ssl
ADD  ./files/ssl_gen/openssl.cnf /tmp/crypto_gen/ssl/
ADD  ./files/ssl_gen/ssl_certs.sh /tmp/crypto_gen/ssl/
RUN  backcd=`pwd` \
  && cd /tmp/crypto_gen/ssl \
  && chmod +x ssl_certs.sh \
  && ./ssl_certs.sh clean \
  && ./ssl_certs.sh generate \
  && cd $backcd


# RabbitMQ - dependancy on erlang
ADD ./files/repos/rabbitmq-erlang.repo /etc/yum.repos.d
# this gets trickier
# 1. there are bunch of dependencies needed from epel before installing RabbitMQ
# 2. there is an older erlang inside epel
# 3. for installing RabbitMQ with yum from rpm file we need wget
# so there`s exact procedure to do this
RUN yum install -y erlang \
  && rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
  && yum -y install wget \
  && rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc \
  && wget https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_10/rabbitmq-server-3.6.10-1.el6.noarch.rpm  \
  && mv rabbitmq-server-3.6.10-1.el6.noarch.rpm /tmp/ \
  && yum install -y /tmp/rabbitmq-server-3.6.10-1.el6.noarch.rpm \
  && mkdir -p /etc/rabbitmq/ssl \
  && cp /tmp/crypto_gen/ssl/server_cert.pem /etc/rabbitmq/ssl/cert.pem \
  && cp /tmp/crypto_gen/ssl/server_key.pem /etc/rabbitmq/ssl/key.pem \
  && cp /tmp/crypto_gen/ssl/testca/cacert.pem /etc/rabbitmq/ssl/
ADD ./files/configs/rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management
# RabitMQ Message Broker
EXPOSE 5671
# RabitMQ Management
EXPOSE 15672


# Redis - epel repo needed
RUN yum install -y redis
# Redis
EXPOSE 6379


# Sensu server, client and api - sensu repo needed
ADD ./files/repos/sensu.repo /etc/yum.repos.d
RUN yum install -y sensu
ADD ./files/configs/config.json /etc/sensu/
RUN mkdir -p /etc/sensu/ssl \
  && cp /tmp/crypto_gen/ssl/client_cert.pem /etc/sensu/ssl/cert.pem \
  && cp /tmp/crypto_gen/ssl/client_key.pem /etc/sensu/ssl/key.pem
# Sensu API
EXPOSE 4567


# Uchiwa - sensu repo needed
RUN yum install -y uchiwa
ADD ./files/configs/uchiwa.json /etc/sensu/
# Uchiwa web front end
EXPOSE 3000

# supervisord
RUN yum install -y supervisor \
  && rm -rf /etc/supervisord.conf
ADD ./files/configs/supervisord.conf  /etc/supervisord.conf
RUN chmod +rw /etc/supervisord.conf

COPY ./docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]