#!/bin/sh

helm repo add jetstack https://charts.jetstack.io   
helm repo update

kubectl create namespace cert-manager

helm install --force cert-manager jetstack/cert-manager --namespace cert-manager --version v1.10.1 --set installCRDs=true  