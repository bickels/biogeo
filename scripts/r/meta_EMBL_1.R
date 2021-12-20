##### EMBL: create a list of fastq files

## create a list to download fasta files
PRJEB19856 <- read.delim("https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB19856&result=read_run", header=T, stringsAsFactors=F)[, c('run_accession', 'sample_alias', 'submitted_ftp')]

ftp <- strsplit(PRJEB19856$submitted_ftp, ';')
forward <- sapply(ftp, function(x) x[1])
reverse <- sapply(ftp, function(x) x[2])

## create a folder if not exist
dir.create("./data/EMBL", recursive =T, showWarnings=F)

write.table(forward, './data/EMBL/download_forward.txt', sep=',', col.names = F, row.names = F, quote = F)
write.table(reverse, './data/EMBL/download_reverse.txt', sep=',', col.names = F, row.names = F, quote = F)
