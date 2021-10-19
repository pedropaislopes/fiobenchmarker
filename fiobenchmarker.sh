#!/bin/bash

COMUM="--runtime=60 --group_reporting=1 --directory=$PWD/fiotest --iodepth=1 --ioengine=mmap --filename_format=CAPPcache.\$jobnum --output-format=normal,terse"
sequencia="1 2 4 8 12 16 24 32 40 50 60"
cache=12000

nvCPUs=$(nproc --all)
maxPG2=$((nvCPUs - 4))


for ncores in $sequencia; do
	if [ $ncores -le $maxPG2 ]; then
		NPG2="$NPG2$ncores "
	fi
done

if [ ! -d $PWD/fiotest ]; then
	mkdir $PWD/fiotest
	if [ $? -ne 0 ]; then
		echo "Erro ao criar diretório $PWD/fiotest"
		exit 1
	fi
fi

function fazBenchmark() {

	nome="$1"
	extras="$2"
	pg2="$3"

	tamanho=$((cache / pg2))
	p=$(printf %02d $pg2)

	echo "fio --size=${tamanho}m --numjobs=$pg2 $COMUM $extras --name=$nome" | tee $nome-$p.out
	fio --size=${tamanho}m --numjobs=$pg2 $COMUM $extras --name=$nome 2>&1 | tee -a $nome-$p.out
	echo "################################################################"
	echo "################################################################"
	echo "################################################################"
	echo "################################################################"
	sync

}

for pg2 in $NPG2; do
	fazBenchmark CAPPDiskSequential "--rw=read" $pg2
	fazBenchmark CAPPDiskRandom "--rw=randread" $pg2
	fazBenchmark CAPPMemorySequential "--rw=read --pre_read=1 --runtime=10 --time_based=1" $pg2
	fazBenchmark CAPPMemoryRandom "--rw=randread --pre_read=1 --runtime=10 --time_based=1" $pg2

	rm -f $PWD/fiotest/*
done
