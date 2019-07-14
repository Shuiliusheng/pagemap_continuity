#!/bin/bash
for dir in `ls`
do
    if [ -d $dir ];then
        echo $dir
        find ./$dir -name "pagemap*" |wc -l
        rm $dir/log
    fi
done
