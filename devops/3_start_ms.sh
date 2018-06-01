#!/bin/bash

CURRENT_PATH=`pwd`

if [ $# -gt 0 ] && [ $1 -eq 1 ]; then
  update-lib
  for MS in `cat ./tmp/list-ms.txt`; do
    echo "==== build & compile for ${MS}"
    cd ${CURRENT_PATH}/../../$MS
    git pull && mvn clean install
  done
fi

for MS in `cat ./tmp/list-ms.txt`; do
  if [ -e ${CURRENT_PATH}/tmp/run.pid ] && [ `grep -c $MS ${CURRENT_PATH}/tmp/run.pid 2>/dev/null` -ne 0 ]; then
      PID=`grep $MS ${CURRENT_PATH}/tmp/run.pid | cut -d' ' -f2`
      echo "==== ${MS} running with pid $PID"
  elif [ ! -e ${CURRENT_PATH}/tmp/run.pid ] || [ `grep -c $MS ${CURRENT_PATH}/tmp/run.pid 2>/dev/null` -eq 0 ]; then
      cd ${CURRENT_PATH}/../../$MS
      nohup java -jar target/*.jar > /dev/null 2>&1 & echo "$MS $!" >> ${CURRENT_PATH}/tmp/run.pid
      echo "==== start java in background process for ${MS} $!"
  fi
done
