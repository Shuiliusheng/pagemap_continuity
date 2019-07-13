#!/bin/bash

ARGC=$# 
if [[ "$ARGC" < 2 ]]; then
    echo "./xxx.sh bench(perlbench) dir"
    exit
fi

bench=$1
dirname=$2

mkdir -p $dirname

#ps -ef |grep "./$bench"
# test the bench is running or not
test=`ps -ef |grep "./$bench"|wc -l`
if [ "$test" = "1" ];then
    echo $bench is not running
    exit
fi

# if running, get the process pid
for line in `ps -ef |grep "./$bench"|awk '{print $2}'`
do
    pid=$line
    break
done
echo pid:$pid

# get the process memory map
n=1
for line in `cat /proc/$pid/maps |awk -F '-' '{print $1" "$2}'|awk '{print "0x"$1" 0x"$2}'`
do
    if [ "$n" = "1" ];then
	last_line=$line	
        n=0
        continue
    elif [ "$n" = "0" ];then
	./pagemap $pid $last_line $line $dirname &
        n=1
    fi
done
