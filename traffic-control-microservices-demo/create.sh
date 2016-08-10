#!/bin/bash

kubectl create -f wholeWeaveDemo-copy.yaml

sleep 15
kubectl create -f scope.yaml

