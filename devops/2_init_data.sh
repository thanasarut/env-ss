#!/bin/bash

TEMP_PATH=./tmp

mkdir ${TEMP_PATH}
cbq --script="select * from authenticate where meta().id = 'email::admin@sunseries.travel'" -engine http://couchbase.int.bkk1.sunseries.travel:8091 -u Administrator -p 090CE11ce | awk 'NR>3 {print}' | jq -c '.results[0].authenticate' > ${TEMP_PATH}/temp.json

echo 'insert into authenticate (key,value) values("email::admin@sunseries.travel",'`cat ${TEMP_PATH}/temp.json)`';' > ${TEMP_PATH}/init-data.n1ql

cbq --script="select * from authenticate where meta().id = 'permission::vick.thanasarut@sunseries.travel'" -engine http://couchbase.int.bkk1.sunseries.travel:8091 -u Administrator -p 090CE11ce | awk 'NR>3 {print}' | jq -c '.results[0].authenticate' > ${TEMP_PATH}/temp.json

echo 'insert into authenticate (key,value) values("permission::admin@sunseries.travel",'`cat ${TEMP_PATH}/temp.json`');' >> ${TEMP_PATH}/init-data.n1ql

rm ${TEMP_PATH}/temp.json

cbq -f ${TEMP_PATH}/init-data.n1ql -engine http://couchbase:8091 -u Administrator -p 090CE11ce

rm ${TEMP_PATH}/init-data.n1ql
rm -fr ${TEMP_PATH}
