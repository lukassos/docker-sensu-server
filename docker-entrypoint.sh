#!/bin/bash
/etc/init.d/redis start
/etc/init.d/rabbitmq-server start
/etc/init.d/sensu-server start
/etc/init.d/sensu-api start
/etc/init.d/uchiwa start
