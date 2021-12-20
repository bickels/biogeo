#!/bin/bash

path=$PWD

## create a list of sequences then download
Rscript $path/scripts/r/meta_EMBL_1.R

mkdir -p $path/data/EMBL/fastq/c0-forward
mkdir -p $path/data/EMBL/fastq/c0-reverse

cd $path

## download forward sequences
name=( $(awk -F',' '{print $1}' $path/data/EMBL/download_forward.txt) )
cd $path/data/EMBL/fastq/c0-forward
echo "downloading forward sequences ..."
echo $(printf '%s\n' "${name[@]}") | xargs -n 1 -P 9 wget -q
echo "done"

## wrong file name
mv G2761a.1.fq.gz.1 G2761a_F.1.fq.gz

## download reverse sequences
name=( $(awk -F',' '{print $1}' $path/data/EMBL/download_reverse.txt) )
cd $path/data/EMBL/fastq/c0-reverse
echo "downloading reverse sequences ..."
echo $(printf '%s\n' "${name[@]}") | xargs -n 1 -P 9 wget -q
echo "done"

## wrong file name
mv G2761a.2.fq.gz.1 G2761a_F.2.fq.gz

## create a metadata file and .csv file for joining sequences
cd $path
Rscript $path/scripts/r/meta_EMBL_2.R