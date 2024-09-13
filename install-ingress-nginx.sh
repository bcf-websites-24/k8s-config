#!/bin/sh

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
helm repo update

kubectl create namespace ingress-nginx

helm install --force ingress-nginx ingress-nginx/ingress-nginx --set controller.publishService.enabled=true -n ingress-nginx --version 4.11.2
