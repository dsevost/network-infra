#!/bin/bash

ADDR=$(/usr/bin/dig +short @127.0.0.1 -p 8053 ns1.${MASTER_LOCAL_ZONE_NAME})
[ -z "$ADDR" ] && exit 1 || exit 0
