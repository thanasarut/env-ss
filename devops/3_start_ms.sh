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
  # no process of that ms running
    cd ${MS_SRC_CODE_PATH}/$MS
    nohup java -Xmx256m -jar target/*.jar > /dev/null 2>&1 &
    echo "==== start java in background process for ${MS} $!"
    if [ -e ${CURRENT_PATH}/${TEMP}/run.pid ]; then
    # log file of running is exist
      OLD_PID=`cat ${CURRENT_PATH}/${TEMP}/run.pid | awk '/$MS / {print $2}'`
      if [ "${OLD_PID}" != "" ]; then
        sed -i '' 's/ ${OLD_PID}$/ $!/g' ${CURRENT_PATH}/${TEMP}/run.pid
      else
        echo "$MS $!" >> ${CURRENT_PATH}/${TEMP}/run.pid
      fi
    else
        echo "$MS $!" >> ${CURRENT_PATH}/${TEMP}/run.pid
    fi
  elif [ -e ${CURRENT_PATH}/${TEMP}/run.pid ]; then
  # process still running && log file of running is exist
    if [ `cat ${CURRENT_PATH}/${TEMP}/run.pid | cut -d' ' -f1 | grep -c $MS$ 2>/dev/null` -ne 0 ]; then
    # found PID of process in log file
      PID=`cat ${CURRENT_PATH}/${TEMP}/run.pid | awk '{print $0, $1}' | cut -d' ' -f2,3 | grep $MS$ | cut -d' ' -f1`
      echo "==== ${MS} running with pid $PID"
    else
    # not found PID of proces in log file
      PID=`ps -ef | grep jar$ | grep $MS | awk '{print $2}'`
      echo "$MS $PID" >> ${CURRENT_PATH}/${TEMP}/run.pid
      echo "==== ${MS} running with pid $PID"
    fi
  else
  # process still running && no log file exist
    PID=`ps -ef | grep jar$ | grep $MS | awk '{print $2}'`
    echo "$MS $PID" >> ${CURRENT_PATH}/${TEMP}/run.pid
    echo "==== ${MS} running with pid $PID"
  fi
done
