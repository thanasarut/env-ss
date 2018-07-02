#!/bin/bash

CURRENT_PATH=`pwd`
MS_SRC_CODE_PATH=$HOME/sunseries
SRC=src
TEMP=tmp

if [ ! -e ./${TEMP} ]; then
  mkdir ./${TEMP}
fi
if [ $# -gt 0 ] && [ $1 -eq 1 ]; then
  update-lib
  for MS in `cat ./${SRC}/list-ms.txt | grep -v "^#"`; do
    echo "==== build & compile for ${MS}"
    cd ${MS_SRC_CODE_PATH}/$MS
    git pull && mvn clean install
  done
fi

for MS in `cat ${SRC}/list-ms.txt | grep -v "^#"`; do
  if [ `ps -ef | grep jar$ | grep -c $MS` -eq 0 ]; then
    cd ${MS_SRC_CODE_PATH}/$MS
    nohup java -Xmx256m -jar target/*.jar > /dev/null 2>&1 &
    if [ -e ${CURRENT_PATH}/${TEMP}/run.pid ]; then
      OLD_PID=`cat ${CURRENT_PATH}/${TEMP}/run.pid | awk '/$MS / {print $2}'`
	echo ${OLD_PID}
      if [ "${OLD_PID}" != "" ]; then
        sed -i '' 's/ ${OLD_PID}$/ $!/g' ${CURRENT_PATH}/${TEMP}/run.pid
      else
        echo "$MS $!" >> ${CURRENT_PATH}/${TEMP}/run.pid
      fi
    else
        echo "$MS $!" >> ${CURRENT_PATH}/${TEMP}/run.pid
    fi
    echo "==== start java in background process for ${MS} $!"
  elif [ -e ${CURRENT_PATH}/${TEMP}/run.pid ] && [ `cat ${CURRENT_PATH}/${TEMP}/run.pid | cut -d' ' -f1 | grep -c $MS$ 2>/dev/null` -ne 0 ]; then
    PID=`cat ${CURRENT_PATH}/${TEMP}/run.pid | awk '{print $0, $1}' | cut -d' ' -f2,3 | grep $MS$ | cut -d' ' -f1`
    echo "==== ${MS} running with pid $PID"
  elif [ ! -e ${CURRENT_PATH}/${TEMP}/run.pid ] || [ `cat ${CURRENT_PATH}/${TEMP}/run.pid | cut -d' ' -f1 | grep -c $MS$ 2>/dev/null` -eq 0 ]; then
    cd ${MS_SRC_CODE_PATH}/$MS
echo "no file run.pid exists"
    nohup java -Xmx256m -jar target/*.jar > /dev/null 2>&1 & echo "$MS $!" >> ${CURRENT_PATH}/${TEMP}/run.pid
    echo "==== start java in background process for ${MS} $!"
  fi
done
