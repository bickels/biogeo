#!/bin/bash

path=$PWD

## create a metadata file and ERX
Rscript $path/scripts/r/meta_EMP_1.R

## map from ERX to links

mkdir -p $path/data/EMP/download
cd $path/data/EMP/download

file=$path/data/EMP/ERX.txt
echo "downloading ERX ..."
while IFS=',' read -a col1
    do
      curl -s "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=${col1}&result=read_run&fields=submitted_ftp" | grep -v "^secondary_sample_accession" > $col1.txt
    done < $file
echo "done"

## merge the links
cd $path
Rscript $path/scripts/r/meta_EMP_2.R

## download according to links
mkdir -p $path/data/EMP/fastq
cd $path/data/EMP/fastq

name=( $(awk -F',' '{print $1}' $path/data/EMP/download.txt) )
echo "downloading sequences ..."
echo $(printf '%s\n' "${name[@]}") | xargs -n 1 -P 10 wget -q
echo "done"

## make folders according to study ID
var=(*.fastq.gz)

for i in ${var[@]}
do
	mkdir -p ${i%%.*}
	mv $i ${i%%.*}/$i
done

