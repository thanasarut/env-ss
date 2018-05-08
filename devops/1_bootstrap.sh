#!/bin/bash

couchbase-cli cluster-init -c couchbase:8091 --cluster-username=Administrator --cluster-password=090CE11ce --cluster-ramsize=2094 --cluster-index-ramsize=256 --service=data,index,query
couchbase-cli bucket-create -c couchbase:8091 -u Administrator -p 090CE11ce --bucket authenticate --bucket-type couchbase --bucket-ramsize 100 --enable-flush 1
couchbase-cli bucket-create -c couchbase:8091 -u Administrator -p 090CE11ce --bucket temporary --bucket-type couchbase --bucket-ramsize 100 --enable-flush 1
couchbase-cli bucket-create -c couchbase:8091 -u Administrator -p 090CE11ce --bucket hotels --bucket-type couchbase --bucket-ramsize 100 --enable-flush 1
couchbase-cli bucket-create -c couchbase:8091 -u Administrator -p 090CE11ce --bucket locations --bucket-type couchbase --bucket-ramsize 100 --enable-flush 1
couchbase-cli bucket-create -c couchbase:8091 -u Administrator -p 090CE11ce --bucket ms_translations --bucket-type couchbase --bucket-ramsize 100 --enable-flush 1
sleep 15
cbq -f ./init-index.n1ql -engine http://couchbase:8091 -u Administrator -p 090CE11ce
