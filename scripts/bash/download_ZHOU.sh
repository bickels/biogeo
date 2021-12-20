#!/bin/bash

path=$PWD

## create a meta file
Rscript $path/scripts/r/meta_ZHOU.R

mkdir -p $path/data/ZHOU/fastq
cd $path/data/ZHOU/fastq

name=( $(awk -F',' '{print $1}' $path/data/ZHOU/download.txt) )
echo "downloading sequences ..."
echo $(printf '%s\n' "${name[@]}") | xargs -n 1 -P 10 wget -q
echo "done"