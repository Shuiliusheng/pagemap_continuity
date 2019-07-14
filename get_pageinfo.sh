#!/bin/bash

ARGC=$# 
if [[ "$ARGC" < 1 ]]; then
    echo "./xxx.sh bench(perlbench)"
    exit
fi

bench=$1
cycle_time=30  # 1200s
output_dir=/home/cuihongwei/test/pagemap/result/$bench

#wait bench running for 100s
sleep 10

while true
do
	#ps -ef |grep "./$bench"
	# test the bench is running or not
	test=`ps -ef |grep "./$bench"|wc -l`
	if [ "$test" = "1" ];then
		echo $bench is not running
		tmux kill-session -t pagemap_$bench
		exit
	fi

	# create dir for record results
	curTime=$(date "+%y%m%d-%H%M%S")
    dirname=$output_dir/$curTime
    mkdir -p $dirname
	# if running, get the process pid
	for line in `ps -ef |grep "./$bench"|awk '{print $2}'`
	do
		pid=$line
		break
	done
	echo pid:$pid

	# get the process memory map
	n=1
	cat /proc/$pid/maps
	for line in `cat /proc/$pid/maps |awk -F '-' '{print $1" "$2}'|awk '{print "0x"$1" 0x"$2}'`
	do
		if [ "$n" = "1" ];then
			last_line=$line	
			n=0
			continue
		elif [ "$n" = "0" ];then
			./subpagemap $pid $last_line $line $dirname 
			n=1
		fi
	done	
       chmod a+wrx $dirname -R	
	# wait for 20 minutes
	sleep $cycle_time
done

