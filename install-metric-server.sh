#!/bin/sh

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

kubectl create namespace metrics-server

helm upgrade --install metrics-server metrics-server/metrics-server --namespace metrics-server