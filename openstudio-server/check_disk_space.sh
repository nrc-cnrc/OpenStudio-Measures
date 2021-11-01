#!/bin/bash
echo "WORKER"
docker exec ${PWD##*/}"_worker_1" sh -c 'df -h .'
#echo "WORKER /mnt/openstudio"
#docker exec ${PWD##*/}"_worker_1" sh -c 'du -sh /mnt/openstudio/*'
#echo "WORKER /var/os-gems"
#docker exec ${PWD##*/}"_worker_1" sh -c 'du -sh /var/gems'
#echo "QUEUE"
#docker exec ${PWD##*/}"_queue_1" sh -c 'df -h '
#echo "DB"
#docker exec ${PWD##*/}"_db_1" sh -c 'df -h '
#echo "DB /data/db"
#docker exec ${PWD##*/}"_db_1" sh -c 'du -sh /data/db'
#echo "WEB"
#docker exec ${PWD##*/}"_web_1" sh -c 'df -h '
#echo "WEB /mnt/openstudio"
#docker exec ${PWD##*/}"_web_1" sh -c 'du -sh /mnt/openstudio'
#echo "WEB_BACKGROUND"
#docker exec ${PWD##*/}"_web-background_1" sh -c 'df -h '
