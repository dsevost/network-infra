#!/bin/bash

/usr/bin/rndc -k /etc/named_ro/rndc.key -p 1953 $*
