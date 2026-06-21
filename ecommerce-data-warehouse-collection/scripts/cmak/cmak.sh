#! /bin/bash

 

case $1 in

"start"){

       echo " -------- 启动 KafkaManager -------"

       nohup /opt/module/cmak-3.0.0.7/bin/cmak   -Dhttp.port=7456 >start.log 2>&1 &

};;

"stop"){

       echo " -------- 停止 KafkaManager -------"

       ps -ef | grep ProdServerStart | grep -v grep |awk '{print $2}' | xargskill 

};;

esac
