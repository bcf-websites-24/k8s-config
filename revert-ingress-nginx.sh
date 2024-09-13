#!/bin/sh

helm upgrade ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f old-values.yaml --version 4.11.2