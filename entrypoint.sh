#!/bin/sh
chown -R mongod:mongod /var/lib/mongo
chown -R mongod:mongod /var/log/mongodb
exec "$@" 
