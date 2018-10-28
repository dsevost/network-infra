#!/bin/bash

/usr/sbin/rndc -k /etc/named_ro/rndc.key -p 1953 $*
