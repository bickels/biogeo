## taxonomy filter

args <- commandArgs(trailingOnly = T)

tab <- read.delim(args[1], header=T, stringsAsFactors = F)
filter <- tab$X.OTUID[grep('Archaea|Unassigned',tab$taxonomy)]
write.table(filter, args[2], col.names = F, row.names = F, quote = F)