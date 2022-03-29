#!/bin/bash

# Variables
__cloudwatch_agent_config='
{
   "agent":{
      "metrics_collection_interval":60,
      "run_as_user":"root"
   },
   "metrics":{
      "metrics_collected":{
         "disk":{
            "measurement":[
               "used_percent"
            ],
            "metrics_collection_interval":60,
            "resources":[
               "*"
            ]
         },
         "mem":{
            "measurement":[
               "mem_used_percent"
            ],
            "metrics_collection_interval":60
         },
         "statsd":{
            "metrics_aggregation_interval":60,
            "metrics_collection_interval":10,
            "service_address":":8125"
         },
         "collectd":{
            "name_prefix":"Collectd_metrics_",
            "metrics_aggregation_interval":120
         }
      }
   }
}
'

print_line(){
   echo "############################################################################" 
}

create_swap_memory(){
   print_line
   fallocate -l 2G /swapfile
   chmod 600 /swapfile
   mkswap /swapfile
   swapon /swapfile
   echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
   echo 'vm.swappiness=20' | tee -a /etc/sysctl.conf
   echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf
   print_line
}

install_docker(){
   # Install Docker
   print_line
   curl -fsSL https://get.docker.com | bash
   usermod -aG docker ubuntu

   # Install docker-compose
   curl -L https://github.com/docker/compose/releases/download/v2.3.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   
   print_line   
}

create_self_signed_ssl(){
   print_line
   openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
      -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/CN=example.com" \
      -addext "subjectAltName=DNS:example.com,DNS:www.example.net,IP:10.0.0.1"

   print_line      
}

install_cloudwatch_agent(){
   print_line
   curl -L https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -o /tmp/amazon-cloudwatch-agent.deb
   dpkg -i -E /tmp/amazon-cloudwatch-agent.deb
   
   # Configure cloudwatch agent and enable in systemd
   echo "$__cloudwatch_agent_config" > /opt/aws/amazon-cloudwatch-agent/bin/config.json
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
   
   print_line
}

up_docker_containers(){
   curl -L ${bucket_url} -o /tmp/react-app.deb
   dpkg -i /tmp/react-app.deb
   /usr/local/bin/docker-compose -f /opt/react-app/docker-compose.yml up -d  
}


apt-get update
apt-get upgrade -y
apt-get install -y collectd

# Run install requirements e configs
create_swap_memory
install_docker
install_cloudwatch_agent

# Application
create_self_signed_ssl
up_docker_containers
