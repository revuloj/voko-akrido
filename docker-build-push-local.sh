#!/bin/bash

img=voko-akrido

docker build -t $img .
docker tag voko-formiko registry.local:5000/$img
docker push registry.local:5000/$img

