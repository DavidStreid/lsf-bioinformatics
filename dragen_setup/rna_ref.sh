#!/bin/bash

REFERENCE=$1
OUTPUT=$2

/opt/edico/bin/dragen \
  --build-hash-table true \
  --ht-build-rna-hashtable true \
  --enable-cnv true \
  --ht-reference ${REFERENCE} \
  --output-directory ${OUTPUT} 
