#!/bin/bash
file=$1
for bench in `cat $file`
do
   echo $bench
   ./run.sh $bench
done
