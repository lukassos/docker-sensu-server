#!/bin/bash

set -e

exec /etc/init.d/redis start
exec /etc/init.d/rabbitmq-server start
exec /etc/init.d/sensu-server start
exec /etc/init.d/sensu-api start
exec /etc/init.d/uchiwa start


exec "$@"