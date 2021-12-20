##### EMBL: create a mapping file

## creat metadata file
## https://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP021922
info <- read.delim("./table/accession/EMBL/SraRunTable.txt", header=T, stringsAsFactors=F)

embl <- cbind.data.frame(info$Alias, info$geographic_location_longitude, info$geographic_location_latitude, 0.025, 'EMBL')
colnames(embl) <- c('ID', 'lon','lat','depth','study')
write.table(embl, './data/EMBL/meta_embl.csv', sep=',', col.names = T, row.names = F, quote = F)

## for joining sequences
embl <- data.frame(ID=rep(0, 235))

a1 <- list.files('./data/EMBL/fastq/C0-forward')
embl$ID <- gsub('\\..*', '', a1)
a <- rep(embl$ID, each=2)

## forward/reverse are mixed in "*.1.fq.gz" and "*.2fq.gz", need to extract them

b1 <- paste(rep(c('$PWD/c2-forward/', '$PWD/c2-reverse/'), length(embl$ID)), rep(embl$ID, each=2), rep(c('.1.fq.gz', '.2.fq.gz'), length(embl$ID)), sep='')
b2 <- paste(rep(c('$PWD/c2-reverse/', '$PWD/c2-forward/'), length(embl$ID)), rep(embl$ID, each=2), rep(c('.2.fq.gz', '.1.fq.gz'), length(embl$ID)), sep='')

c <- rep(c('forward','reverse'), length(embl$ID))
forward <- cbind.data.frame(a,b1,c); colnames(forward) <- c('sample-id','absolute-filepath','direction')
reverse <- cbind.data.frame(a,b2,c); colnames(reverse) <- c('sample-id','absolute-filepath','direction')
write.table(forward, file='./data/EMBL/forward.csv', sep=',', col.names =T, row.names = F, quote=F)
write.table(reverse, file='./data/EMBL/reverse.csv', sep=',', col.names =T, row.names = F, quote=F)
