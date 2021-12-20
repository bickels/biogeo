##### EMP: create a list for sequences

library(data.table)

lst <- list()
path <- './data/EMP/download'
for (i in 1:length(list.files(path=path, pattern='.*.txt'))){
  lst[[i]] <- read.delim(list.files(path=path, pattern='.*.txt', full.names = T)[i], header=T)$submitted_ftp
}
write.table(unlist(lst), './data/EMP/download.txt', col.names = F, row.names = F, quote = F)
