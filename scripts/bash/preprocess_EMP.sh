#!/bin/bash

path=$PWD
trainer_gg=$path/data/gg_13_8_otus/gg-13-8-99-515-806-nb-classifier.qza

## packages
qiime2=qiime2-2018.8
qiime1=qiime1-1.9.1
deblur=deblur-1.1.0

mkdir -p $path/data/EMP/biom/all
mkdir -p $path/data/EMP/fasta

cd $path/data/EMP/fastq

file=(*)
for i in ${file[@]}
do  
  ## quality filter
  echo "processing study:" $i "..."
	source /anaconda3/bin/activate $qiime1
	cd $path/data/EMP/fastq/$i
	var=$(find . -not -path '*/\.*' -name '*.fastq.gz' | paste -s -d ',' -)
	fn=$(find . -not -path '*/\.*' -name "*.fastq.gz" -execdir sh -c 'printf "%s\n" "${0%.fastq.gz}"' {} ';' | paste -s -d ',' -)

	split_libraries_fastq.py -i $var --barcode_type 'not-barcoded' -o $path/data/EMP/fasta/$i --sample_ids $fn --phred_offset 33 

	cd $path/data/EMP/fasta/$i

  ## cleaning
	cat seqs.fna | \
        egrep 'ATCTCGTATGCCGTCTTCTGC|GCAGAAGACGGCATACGAGAT|GTAGTCCGGCTGACTGACT|AGTCAGTCAGCCGGACTAC|GATCGGAAGAGCACACGTCT|AAAAAAAAAAAAAAAAAAAA|GGGGGGGGGGGGGGGGGGGG|GTGCCAGCAGCCGCGGTAA|GTGCCAGCCGCCGCGGTAA' \
            -B 1 | grep -v -- "^--$" > seqs_to_filter.fna
  
	filter_fasta.py -f seqs.fna \
                -o seqs_filtered.fna \
                -a seqs_to_filter.fna \
                -n

  # denoising
  source /anaconda3/bin/activate $deblur
	deblur workflow --seqs-fp seqs_filtered.fna --output-dir deblur -t 90 --min-reads 1 --min-size 2 -w -O 4
done

## biom
cd $path/data/EMP/fasta
source /anaconda3/bin/activate $qiime1
var=$(find . -name 'all.biom' | paste -s -d ',' -)
parallel_merge_otu_tables.py -i $var -o $path/data/EMP/biom/
 
## repseqs
cd $path/data/EMP/fasta
source /anaconda3/bin/activate $qiime2
var=(*)
for i in ${var[@]}
do
    cd $path/data/EMP/fasta/$i/deblur
    qiime tools import \
      --input-path all.seqs.fa \
      --output-path $path/data/EMP/biom/all/$i.qza \
      --type 'FeatureData[Sequence]'
done

cd $path/data/EMP/biom/all
var=(*.qza)
sep=" --i-data "
bar=$(printf "${sep}%s" ${var[@]})

qiime feature-table merge-seqs $bar --o-merged-data $path/data/EMP/biom/repseqs.qza

## taxonomy
echo "classifying ..."
qiime feature-classifier classify-sklearn \
  --i-classifier $trainer_gg \
  --i-reads $path/data/EMP/biom/repseqs.qza\
  --o-classification $path/data/EMP/biom/taxonomy.qza \
  --p-n-jobs 2 \
  --p-reads-per-batch 30000 \
  --p-read-orientation same

cd $path/data/EMP/biom
qiime tools export --input-path taxonomy.qza --output-path ./

## change the header in order to export
sed $'1s/.*/#OTUID\ttaxonomy\tconfidence/' taxonomy.tsv > taxonomy_new.tsv

## create a biom table with taxonomy
biom add-metadata -i merged.biom -o taxonomy.biom --observation-metadata-fp taxonomy_new.tsv --sc-separated taxonomy