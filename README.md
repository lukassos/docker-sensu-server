# docker-sensu-server

Sensu / Uchiwa monitoring node
It is based on CentOS 6 with latest RabbitMQ and sensu installed

Utilizing both sensu-server and sensu-api to get the latest info on your infrastructure

It has one single point of entry and in case of failure just restart the container. 

If you are new to Sensu just read this great intro : https://github.com/joemiller/joemiller.me-intro-to-sensu/blob/master/intro-to-sensu.md
                                                     
 
## Installation

Install from Docker Hub

```
docker pull hiroakis/docker-sensu-server
```

or build from Dockerfile

```
git clone https://github.com/lukassos/docker-sensu-server.git
cd docker-sensu-server
docker build -t yourname/docker-sensu-server .
```

## Run

```
docker run -d  -p 7654:3000 -p 4567:4567 -p 5671:5671 -p 15672:15672 lukassos/docker-sensu-server
```
This opens few ports on both container and host machines. 
You can change them as you like in the Dockerfile.
  
EXPOSEd ports on container side:
* 3000 - Uchiva web frontend
* 4567 - Sensu API
* 5671 - RabbitMQ message broker
* 15672 - RabbitMQ mangement 

Host ports used by command above: 
* 7654 - Uchiva web frontend - Access it for monitoring
* 4567 - Sensu API
* 5671 - RabbitMQ message broker
* 15672 - RabbitMQ mangement 

## How to access via browser and sensu-client

### rabbitmq console

* http://your-server:15672/
* username : usnes
* password : MonitoringPW

### uchiwa

* http://your-server:3000/

### sensu-client

To run sensu-client, create client.json (see example below), then just run sensu-client process.

These are examples of sensu-client configuration.

* /etc/sensu/config.json

```
{
  "rabbitmq": {
    "host": "sensu-server-ipaddr",
    "port": 5671,
    "vhost": "/sensu",
    "user": "usnes",
    "password": "MonitoringPW",
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    }
  }
}
```

* /etc/sensu/conf.d/client.json

```
{
  "client": {
    "name": "sensu-client-node-hostname",
    "address": "sensu-client-node-ipaddr",
    "subscriptions": [
      "common",
      "web"
    ]
  },
  "keepalive": {
    "thresholds": {
      "critical": 60
    },
    "refresh": 300
  }
}
```


## License

MIT


### Based upon
* hiroakis :  https://github.com/hiroakis/docker-sensu-server
* joemiller : https://github.com/joemiller/joemiller.me-intro-to-sensu/blob/master/intro-to-sensu.md
