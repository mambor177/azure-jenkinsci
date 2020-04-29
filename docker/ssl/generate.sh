#!/bin/bash
# jenkins-lb.jenkins.svc.cluster.local
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -config req.cnf
openssl rsa -in key.pem -out key_rsa.pem