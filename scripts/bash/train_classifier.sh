#!/bin/bash

path=$PWD

## packages
qiime2=qiime2-2018.8

## train classifier using GreenGenes 13_8
## http://qiime.org/home_static/dataFiles.html
## https://docs.qiime2.org/2019.1/tutorials/feature-classifier/

mkdir -p $path/data
cd $path/data

wget "ftp://greengenes.microbio.me/greengenes_release/gg_13_5/gg_13_8_otus.tar.gz"
tar -xzf gg_13_8_otus.tar.gz

cd $path/data/gg_13_8_otus
source /anaconda3/bin/activate $qiime2
echo "importing ..."
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path rep_set/99_otus.fasta \
  --output-path 99_otus.qza
  
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path taxonomy/99_otu_taxonomy.txt \
  --output-path ref-taxonomy.qza

##### 515-806
echo "extract reads ..."
qiime feature-classifier extract-reads \
  --i-sequences 99_otus.qza \
  --p-f-primer GTGCCAGCMGCCGCGGTAA \
  --p-r-primer GGACTACHVGGGTWTCTAAT \
  --p-trunc-len 90 \
  --o-reads ref-seqs-515-806.qza
   
echo "training ..."
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ref-seqs-515-806.qza \
  --i-reference-taxonomy ref-taxonomy.qza \
  --o-classifier gg-13-8-99-515-806-nb-classifier.qza