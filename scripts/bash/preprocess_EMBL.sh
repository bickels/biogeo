#!/bin/bash

path=$PWD
trainer_gg=$path/data/gg_13_8_otus/gg-13-8-99-515-806-nb-classifier.qza

## packages
qiime2=qiime2-2018.8
qiime1=qiime1-1.9.1
deblur=deblur-1.1.0
cutadapt=cutadapt-1.18

mkdir -p $path/data/EMBL/biom
mkdir -p $path/data/EMBL/fastq/c1-forward
mkdir -p $path/data/EMBL/fastq/c1-reverse
mkdir -p $path/data/EMBL/fastq/c2-forward
mkdir -p $path/data/EMBL/fastq/c2-reverse
mkdir -p $path/data/EMBL/trimmed-joined/forward
mkdir -p $path/data/EMBL/trimmed-joined/reverse

cd $path/data/EMBL/fastq/c0-forward
var=(*.fq.gz)

## filter out new primer sequences
echo "filtering new primer ..."
source /anaconda3/bin/activate $cutadapt
for i in ${var[@]}
do
  cutadapt -g GTGTCAGCMGCCGCGGTAA -G GTGTCAGCMGCCGCGGTAA -o $path/data/EMBL/fastq/c1-forward/${i%%.*}.1.fq.gz -p $path/data/EMBL/fastq/c1-reverse/${i%%.*}.2.fq.gz $path/data/EMBL/fastq/c0-forward/${i%%.*}.1.fq.gz $path/data/EMBL/fastq/c0-reverse/${i%%.*}.2.fq.gz --pair-filter=any --discard-trimmed -m 1 -O 19 -e 0 --no-trim --quiet
done

for i in ${var[@]}
do
  cutadapt -g GGACTACGVGGGTWTCTAAT -G GGACTACGVGGGTWTCTAAT -o $path/data/EMBL/fastq/c2-forward/${i%%.*}.1.fq.gz -p $path/data/EMBL/fastq/c2-reverse/${i%%.*}.2.fq.gz $path/data/EMBL/fastq/c1-reverse/${i%%.*}.2.fq.gz $path/data/EMBL/fastq/c1-forward/${i%%.*}.1.fq.gz --pair-filter=any --discard-trimmed -m 1 -O 20 -e 0 --no-trim --quiet
done

## forward and reverse primer are mixed in the .1 and .2 files
## have to run two times and then combine them
echo "joining sequences ..."
cd $path/data/EMBL/fastq
source /anaconda3/bin/activate $qiime2
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $path/data/EMBL/forward.csv \
  --output-path forward.qza \
  --input-format PairedEndFastqManifestPhred33

qiime vsearch join-pairs \
 --i-demultiplexed-seqs forward.qza \
 --o-joined-sequences forward-join.qza \

qiime tools export --input-path forward-join.qza  --output-path forward/

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $path/data/EMBL/reverse.csv \
  --output-path reverse.qza \
  --input-format PairedEndFastqManifestPhred33

qiime vsearch join-pairs \
 --i-demultiplexed-seqs reverse.qza \
 --o-joined-sequences reverse-join.qza \

qiime tools export --input-path reverse-join.qza  --output-path reverse/

## the default name it not ok, need to be changed
source deactivate
Rscript $path/scripts/r/rename.R

## cut primers
echo "cutting primers ..."
cd $path/data/EMBL/fastq/forward
source /anaconda3/bin/activate $cutadapt
var=(*.fastq.gz)
for i in ${var[@]}
do
  cutadapt -g GTGCCAGCMGCCGCGGTAA -o $path/data/EMBL/trimmed-joined/forward/$i $i --discard-untrimmed -m 1 -O 19 -e 0.1 --quiet
done

cd $path/data/EMBL/fastq/reverse
var=(*.fastq.gz)
for i in ${var[@]}
do
  cutadapt -g GTGCCAGCMGCCGCGGTAA -o $path/data/EMBL/trimmed-joined/reverse/$i $i --discard-untrimmed -m 1 -O 19 -e 0.1 --quiet
done

## quality control
## empty sample "S017" will be removed later
echo "quality filtering ..."
source /anaconda3/bin/activate $qiime1
cd $path/data/EMBL/trimmed-joined/forward/
var=$(find . -not -path '*/\.*' -name '*fastq.gz' | paste -s -d ',' -)
fn=$(find . -not -path '*/\.*' -name "*fastq.gz" -execdir sh -c 'printf "%s\n" "${0%%.fastq.gz}"' {} ';' | paste -s -d ',' -)
split_libraries_fastq.py -i $var --barcode_type 'not-barcoded' -o $path/data/EMBL/trimmed-joined/qc-forward --sample_ids $fn --phred_offset 33 

cd $path/data/EMBL/trimmed-joined/reverse/
var=$(find . -not -path '*/\.*' -name '*fastq.gz' | paste -s -d ',' -)
fn=$(find . -not -path '*/\.*' -name "*fastq.gz" -execdir sh -c 'printf "%s\n" "${0%%.fastq.gz}"' {} ';' | paste -s -d ',' -)
split_libraries_fastq.py -i $var --barcode_type 'not-barcoded' -o $path/data/EMBL/trimmed-joined/qc-reverse --sample_ids $fn --phred_offset 33 

## combine them
cat $path/data/EMBL/trimmed-joined/qc-forward/seqs.fna $path/data/EMBL/trimmed-joined/qc-reverse/seqs.fna > $path/data/EMBL/trimmed-joined/seqs.fna

cd $path/data/EMBL/trimmed-joined/

cat seqs.fna | \
        egrep 'ATCTCGTATGCCGTCTTCTGC|GCAGAAGACGGCATACGAGAT|GTAGTCCGGCTGACTGACT|AGTCAGTCAGCCGGACTAC|GATCGGAAGAGCACACGTCT|AAAAAAAAAAAAAAAAAAAA|GGGGGGGGGGGGGGGGGGGG|GTGCCAGCAGCCGCGGTAA|GTGCCAGCCGCCGCGGTAA' \
            -B 1 | grep -v -- "^--$" > seqs_to_filter.fna

filter_fasta.py -f seqs.fna \
                -o seqs_filtered.fna \
                -a seqs_to_filter.fna \
                -n

## denoise
echo "denoising ..." 
source /anaconda3/bin/activate $deblur
deblur workflow --seqs-fp seqs_filtered.fna --output-dir deblur -t 90 --min-reads 1 --min-size 2 -w -O 4

cp $path/data/EMBL/trimmed-joined/deblur/all.biom $path/data/EMBL/biom/all.biom

## classification
echo "classifying ..."
source /anaconda3/bin/activate $qiime2
qiime tools import \
  --input-path $path/data/EMBL/trimmed-joined/deblur/all.seqs.fa \
  --output-path $path/data/EMBL/biom/repseqs.qza \
  --type 'FeatureData[Sequence]'

qiime feature-classifier classify-sklearn \
  --i-classifier $trainer_gg \
  --i-reads $path/data/EMBL/biom/repseqs.qza\
  --o-classification $path/data/EMBL/biom/taxonomy.qza \
  --p-n-jobs 2 \
  --p-reads-per-batch 30000 \
  --p-read-orientation same

cd $path/data/EMBL/biom
qiime tools export --input-path taxonomy.qza --output-path ./

## change the header in order to export
sed $'1s/.*/#OTUID\ttaxonomy\tconfidence/' taxonomy.tsv > taxonomy_new.tsv

## create a biom table with taxonomy
biom add-metadata -i all.biom -o taxonomy.biom --observation-metadata-fp taxonomy_new.tsv --sc-separated taxonomy