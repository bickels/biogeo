#!/bin/bash

path=$PWD
path1=$path/data/EMBL
path2=$path/data/EMP
path3=$path/data/ZHOU

## packages
qiime1=qiime1-1.9.1

mkdir -p $path/data/biom

## merge biom table
source /anaconda3/bin/activate $qiime1
# parallel_merge_otu_tables.py -i $path1/biom/taxonomy.biom,$path2/biom/taxonomy.biom,$path3/biom/taxonomy.biom -o $path/data/biom/

## create a list for filtering (unassigned and archaea)
source deactivate
Rscript $path/fun/taxa_filter.R $path1/biom/taxonomy_new.tsv $path/data/biom/seqs_to_filter_1.txt
Rscript $path/fun/taxa_filter.R $path2/biom/taxonomy_new.tsv $path/data/biom/seqs_to_filter_2.txt
Rscript $path/fun/taxa_filter.R $path3/biom/taxonomy_new.tsv $path/data/biom/seqs_to_filter_3.txt

## combine txt file
cat $path/data/biom/seqs_to_filter_1.txt $path/data/biom/seqs_to_filter_2.txt $path/data/biom/seqs_to_filter_3.txt > $path/data/biom/non-rep.txt

## clean
source /anaconda3/bin/activate $qiime1
filter_otus_from_otu_table.py -i $path/data/biom/merged.biom -o $path/data/biom/taxonomy.biom -e $path/data/biom/non-rep.txt

## create one biom without global singletons, used for choosing rarefaction
filter_otus_from_otu_table.py -i $path/data/biom/taxonomy.biom -o $path/data/biom/taxonomy-raw.biom -e $path/data/biom/non-rep.txt -n 2