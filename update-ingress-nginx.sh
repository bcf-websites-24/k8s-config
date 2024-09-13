#!/bin/sh

helm upgrade ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f nginx-values.yaml --version 4.11.2