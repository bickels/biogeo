##### change file names according to MANIFEST

wd <- getwd()

setwd(paste(wd, '/reverse', sep=''))
filename <- read.delim('MANIFEST', sep=',', header=F, skip=4, stringsAsFactors = F)
a <- file.rename(filename$V2, paste(filename$V1, '.fastq.gz', sep=''))

setwd(paste(wd, '/forward', sep=''))
filename <- read.delim('MANIFEST', sep=',', header=F, skip=4, stringsAsFactors = F)
a <- file.rename(filename$V2, paste(filename$V1, '.fastq.gz', sep=''))