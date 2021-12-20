#!/bin/bash

path=$PWD
trainer_gg=$path/data/gg_13_8_otus/gg-13-8-99-515-806-nb-classifier.qza

## packages
qiime2=qiime2-2018.8
qiime1=qiime1-1.9.1
deblur=deblur-1.1.0

mkdir -p $path/data/ZHOU/biom/qc

## quality filter
echo "quality filtering ..."
cd $path/data/ZHOU/fastq
source /anaconda3/bin/activate $qiime1
var=$(find . -not -path '*/\.*' -name '*fastq.gz' | paste -s -d ',' -)
fn=$(find . -not -path '*/\.*' -name "*fastq.gz" -execdir sh -c 'printf "%s\n" "${0%%.fastq.gz}"' {} ';' | paste -s -d ',' -)
split_libraries_fastq.py -i $var --barcode_type 'not-barcoded' -o $path/data/ZHOU/biom/qc --sample_ids $fn --phred_offset 33 

## clean adapter
echo "cleaning adapter ..."
cd $path/data/ZHOU/biom/qc
  cat seqs.fna | \
        egrep 'ATCTCGTATGCCGTCTTCTGC|GCAGAAGACGGCATACGAGAT|GTAGTCCGGCTGACTGACT|AGTCAGTCAGCCGGACTAC|GATCGGAAGAGCACACGTCT|AAAAAAAAAAAAAAAAAAAA|GGGGGGGGGGGGGGGGGGGG|GTGCCAGCAGCCGCGGTAA|GTGCCAGCCGCCGCGGTAA' \
            -B 1 | grep -v -- "^--$" > seqs_to_filter.fna
  
filter_fasta.py -f seqs.fna \
                -o seqs_filtered.fna \
                -a seqs_to_filter.fna \
                -n

## denoising
echo "denoising ..."
source /anaconda3/bin/activate $deblur
deblur workflow --seqs-fp seqs_filtered.fna --output-dir deblur -t 90 --min-reads 1 --min-size 2 -w -O 4

cp $path/data/ZHOU/biom/qc/deblur/all.biom $path/data/ZHOU/biom/all.biom

## taxonomy
echo "classifying ..."
source /anaconda3/bin/activate $qiime2
qiime tools import \
      --input-path $path/data/ZHOU/biom/qc/deblur/all.seqs.fa \
      --output-path $path/data/ZHOU/biom/repseqs.qza \
      --type 'FeatureData[Sequence]'

qiime feature-classifier classify-sklearn \
  --i-classifier $trainer_gg \
  --i-reads $path/data/ZHOU/biom/repseqs.qza\
  --o-classification $path/data/ZHOU/biom/taxonomy.qza \
  --p-n-jobs 2 \
  --p-reads-per-batch 30000 \
  --p-read-orientation same

cd $path/data/ZHOU/biom
qiime tools export --input-path taxonomy.qza --output-path ./

## change the header in order to export
sed $'1s/.*/#OTUID\ttaxonomy\tconfidence/' taxonomy.tsv > taxonomy_new.tsv

## create a biom table with taxonomy
biom add-metadata -i all.biom -o taxonomy.biom --observation-metadata-fp taxonomy_new.tsv --sc-separated taxonomy