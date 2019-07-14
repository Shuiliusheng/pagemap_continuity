#!/bin/bash
for dir in `ls`
do
    if [ -d $dir ];then
        echo $dir
        grep -rn continuity $dir|awk -F ':' '{print $4" "$5}'|awk '{print $1" "$3}' >log
        times=`ls $dir|wc -l`
        echo "pagesize : number (times=$times)"
	./temp
        echo
	rm log
    fi
done
