 #!/bin/sh

REGEX="xmra64"

function getPIDList {
    echo "Get PID List by user: postgres" >> kill_mainer.log
    PIDList=$(ps -ef | grep postgres | awk '{print$2}')
    echo "" >> kill_mainer.log
}

function iteratePIDList {
    for var in $PIDList
    do
    echo "PID in PID List: $var " >> kill_mainer.log
    pathPID=$(readlink -f /proc/${var}/exe)
    echo "path by PID: $pathPID" >> kill_mainer.log
    # testStr="/dev/shm/xmra64 (deleted)"

    checkString=$(echo $pathPID | sed -n '/xmra64/p')
    if [ -z "${checkString}" ]; then
        echo "NOT MATCHING BY REGEX: $REGEX" >> kill_mainer.log
    else
        echo "MATCHING BY REGEX: $REGEX" >> kill_mainer.log
        echo "killing pid: $var" >> kill_mainer.log
        echo "$(kill -KILL $var)" >> kill_mainer.log
    fi
    echo "" >> kill_mainer.log
    done
}

currentDate=`date +"%d-%m-%Y %T"`

echo "$currentDate: kill_mainer.sh start" >> kill_mainer.log
echo "" >> kill_mainer.log

getPIDList

iteratePIDList

currentDate=`date +"%d-%m-%Y %T"`

echo "$currentDate: kill_mainer.sh end" >> kill_mainer.log

echo "" >> kill_mainer.log
