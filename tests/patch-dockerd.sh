#!/bin/bash

echo "{
  \"insecure-registries\" : [\"localhost:32000\"]
}" > /etc/docker/docker.json
systemctl restart docker
