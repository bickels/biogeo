#!/bin/bash

path=$PWD
ID=$path/temp/ID.txt

## packages
qiime1=qiime1-1.9.1

## clean BIOM table by removing singletons and samples with less than 7500 reads
source /anaconda3/bin/activate $qiime1

## global singletons
filter_otus_from_otu_table.py -i $path/data/biom/taxonomy.biom -o $path/data/biom/taxonomy-filtered.biom -n 2

## samples 
filter_samples_from_otu_table.py -i $path/data/biom/taxonomy-filtered.biom -o $path/data/biom/taxonomy-filtered-ID.biom --sample_id_fp $ID

## rarefaction depth
filter_samples_from_otu_table.py -i $path/data/biom/taxonomy-filtered-ID.biom -o $path/data/biom/taxonomy-filtered-ID-rarefied.biom -n 7500

## clean empty rows
filter_otus_from_otu_table.py -i $path/data/biom/taxonomy-filtered-ID-rarefied.biom -o $path/data/biom/taxonomy-cleaned.biom -n 1

## clean temporal files
rm $path/data/biom/taxonomy-filtered.biom $path/data/biom/taxonomy-filtered-ID.biom $path/data/biom/taxonomy-filtered-ID-rarefied.biom

## create two temp files of taxonomy
## 8GB in R not enough
source deactivate
ulimit -s 16384
Rscript $path/scripts/r/read_taxa.R