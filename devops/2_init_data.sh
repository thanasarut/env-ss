#!/bin/bash

TEMP_PATH=./tmp

mkdir ${TEMP_PATH}
echo -n "get user from int"
cbq --script="select * from authenticate where meta().id = 'email::admin@sunseries.travel'" -engine http://couchbase.int.bkk1.sunseries.travel:8091 -u Administrator -p 090CE11ce | awk 'NR>3 {print}' | jq -c '.results[0].authenticate' > ${TEMP_PATH}/temp.json
echo "...done"

echo -n "insert user to local"
echo 'insert into authenticate (key,value) values("email::admin@sunseries.travel",'`cat ${TEMP_PATH}/temp.json`');' > ${TEMP_PATH}/init-data.n1ql
echo "...done"

echo -n "get permission from int"
cbq --script="select * from authenticate where meta().id = 'permission::vick.thanasarut@sunseries.travel'" -engine http://couchbase.int.bkk1.sunseries.travel:8091 -u Administrator -p 090CE11ce | awk 'NR>3 {print}' | jq -c '.results[0].authenticate' > ${TEMP_PATH}/temp.json
echo "...done"

echo -n "insert permission to local"
echo 'insert into authenticate (key,value) values("permission::admin@sunseries.travel",'`cat ${TEMP_PATH}/temp.json`');' >> ${TEMP_PATH}/init-data.n1ql
echo "...done"

rm ${TEMP_PATH}/temp.json

cbq -f ${TEMP_PATH}/init-data.n1ql -engine http://couchbase:8091 -u Administrator -p 090CE11ce

rm ${TEMP_PATH}/init-data.n1ql
rm -fr ${TEMP_PATH}
