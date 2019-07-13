#!/bin/bash

ARGC=$# 
if [[ "$ARGC" < 1 ]]; then
    echo "./xxx.sh bench(perlbench)"
    exit
fi

bench=$1

spec_run_dir=/home/cuihongwei/test/pagemap
spec_run_dir=$spec_run_dir/$bench

cycle_time=300  # 1200s

output_dir=/home/cuihongwei/test/pagemap/result/$bench

# start execute spec bench
tmux new -s pagemap_$bench -d
tmux send-keys -t pagemap_$bench "cd $spec_run_dir" C-m
tmux send-keys -t pagemap_$bench "./run.sh" C-m
sleep 60  # wait for 2 minutes

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
			./pagemap $pid $last_line $line $dirname 
			n=1
		fi
	done	
        chmod a+wrx $dirname -R	
	# wait for 20 minutes
	sleep $cycle_time
done

