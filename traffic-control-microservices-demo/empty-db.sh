#!/bin/bash

kubectl delete deployment cart-db
kubectl create -f wholeWeaveDemo-copy.yaml 2>/dev/null

