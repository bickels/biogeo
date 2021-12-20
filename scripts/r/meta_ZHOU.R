##### ZHOU: download and create a mappting file

dl <- read.delim("https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJNA308872&result=read_run", header=T)
idx <- grep('16S',dl$library_name)
write.table(dl$fastq_ftp[idx],file='./data/ZHOU/download.txt', col.names = F, row.names = F, quote=F, sep=',')

## https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA308872&go=go
meta <- read.delim('./table/accession/ZHOU/SraRunTable.txt', header=T, stringsAsFactors = F)
idx <- grep('16S', meta$Library_Name)

## metadata
lonlat <- data.frame(matrix(unlist(strsplit(meta$lat_lon[idx], ' ')), ncol=4, byrow=T))
lonlat$X1 <- as.numeric(as.character(lonlat$X1))
lonlat$X3 <- as.numeric(as.character(lonlat$X3))
lonlat$X1[lonlat$X2=='S'] =-lonlat$X1[lonlat$X2=='S']
lonlat$X3[lonlat$X4=='W'] =-lonlat$X3[lonlat$X4=='W']

tab <- cbind.data.frame(meta$Run[idx], lonlat$X3, lonlat$X1, '0.05', 'ZHOU')
colnames(tab) <- c('ID','lon','lat','depth','study')
write.table(tab,'./data/ZHOU/meta_zhou.csv', sep=',', col.names = T, row.names = F, quote = F)