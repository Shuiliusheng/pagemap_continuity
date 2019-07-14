#!/bin/bash

ARGC=$# 
if [[ "$ARGC" < 1 ]]; then
    echo "./xxx.sh bench(perlbench)"
    exit
fi

bench=$1

#dir setting
spec_run_dir=/home/cuihongwei/temp_spec2006_running/input1
spec_run_dir=$spec_run_dir/$bench

pagemap_dir=/home/cuihongwei/test/pagemap

# start execute spec bench
tmux new -s pagemap_$bench -d
tmux new -s record_$bench -d

tmux send-keys -t pagemap_$bench "cd $spec_run_dir" C-m
tmux send-keys -t pagemap_$bench "./run.sh" C-m
#sleep 120  # wait for 2 minutes

tmux send-keys -t record_$bench "cd $pagemap_dir" C-m
tmux send-keys -t record_$bench "sudo ./get_pageinfo.sh $bench" C-m
tmux send-keys -t record_$bench "cuihongwei" C-m
