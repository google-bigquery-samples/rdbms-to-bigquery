#!/bin/bash
# run.sh
# @See https://github.com/embulk/embulk

dstPrj=dwprj1
dstSet=ods3
dstTbl=orders
today=$1
yesterday=$(date --date=@$(expr $(date -d$today +%s) - 86400) +%Y%m%d)
yyyymm=$(date -d$yesterday +%Y%m)
extCode=$?

#0 check if duplicate execution
if [ $extCode -eq 0 ]
then
  yml=${dstTbl}_$yesterday.yml.liquid
  if [ -f log/$yyyymm/$yml ]
  then
    extCode=2
    echo "$yml: done already!"
  elif [ -f $yml ]
  then
    extCode=1
    echo "$yml: IN PROGRESS!"
  else
    extCode=0
  fi
fi

#1 load data from MySQL to BigQuery
if [ $extCode -ne 0 ]
then
  exit
else
  cp $dstTbl.yml.template $yml
  sed -i s/__today__/$today/g $yml
  sed -i s/__yesterday__/$yesterday/g $yml
  cat $yml
  $EMBULK_HOME/bin/embulk \
    run $yml
  extCode=$?
fi

#0 mark success, or clean failure
if [ $extCode -eq 0 ]
then
  mv $yml log/$yyyymm/$yml
else
  rm $yml
fi
