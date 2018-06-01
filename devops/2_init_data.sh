#!/bin/bash

cbq --script="select * from authenticate where meta().id = 'email::admin@sunseries.travel'" -engine http://couchbase.int.bkk1.sunseries.travel:8091 -u Administrator -p 090CE11ce | awk 'NR>3 {print}' | jq -c '.results[0].authenticate' > ./tmp/temp.json

echo 'insert into authenticate (key,value) values("email::admin@sunseries.travel",'$(cat temp.json)');' > ./tmp/init-data.n1ql

cbq --script="select * from authenticate where meta().id = 'permission::vick.thanasarut@sunseries.travel'" -engine http://couchbase.int.bkk1.sunseries.travel:8091 -u Administrator -p 090CE11ce | awk 'NR>3 {print}' | jq -c '.results[0].authenticate' > ./tmp/temp.json

echo 'insert into authenticate (key,value) values("permission::admin@sunseries.travel",'$(cat temp.json)');' >> ./tmp/init-data.n1ql

rm ./tmp/temp.json

cbq -f ./tmp/init-data.n1ql -engine http://couchbase:8091 -u Administrator -p 090CE11ce

rm ./tmp/init-data.n1ql
