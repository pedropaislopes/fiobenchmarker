#!/bin/bash

mkdir $PWD/fiotest 2>/dev/null

fio --size=100m --numjobs=12 --runtime=60 --group_reporting=1 --directory=$PWD/fiotest --iodepth=1 --ioengine=mmap --filename_format=COREcache.\$jobnum --output-format=normal,terse --rw=read --name=CAPPDiskSequential 2>&1 | tee CAPPDiskSequential-16.out

echo "#########################################################"
echo "#########################################################"
echo "#########################################################"

fio --size=100m --numjobs=12 --group_reporting=1 --directory=$PWD/fiotest --iodepth=1 --ioengine=mmap --filename_format=COREcache.\$jobnum --output-format=normal,terse --rw=read --pre_read=1 --runtime=10 --time_based=1 --name=CAPPMemorySequential 2>&1 | tee CAPPMemorySequential-16.out
