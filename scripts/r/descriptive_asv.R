##### ASVs description

library(rhdf5)

biom <- './data/biom/merged.biom'
tax <- readRDS('./temp/tax_merged.rds')

## count of species
dat <- h5read(biom, '/sample/matrix/data')
## indices of species, first one is 0
indices <- h5read(biom, '/sample/matrix/indices') +1
## interval between studies, first one is 0
inv <- h5read(biom, '/sample/matrix/indptr') +1
## study id
ids <- h5read(biom, '/sample/ids')
s <- ids

su <- h5ls(biom)
num.species <- max(indices)
H5close()

## need a new full otu table
num <- 1:length(ids)
lb <- inv[num]
ub <- inv[num+1]-1

species <- list()
counts <- list()
for (i in 1:length(num)){
  counts[[i]] <- dat[lb[i]:ub[i]]
  species[[i]] <- indices[lb[i]:ub[i]]
}

otu.full <- matrix(0, nrow=num.species, ncol=length(num))
for (i in 1:length(num)){
  idx.match <- species[[i]]
  otu.full[idx.match, i] <- counts[[i]]
}

## compute col/row sum
v <- apply(otu.full, 2, sum)
w <- apply(otu.full, 1, sum)

## percentage 
cat("number of unique species:", length(w), '\n')
cat("total reads:", sum(w), '\n')
cat("mean reads per sample:", sum(w)/length(ids), '\n')
cat("percentage of single observations:", sum(w==1)/length(w)*100, '\n')
cat("percentage of observations less than ten:", sum(w<10)/length(w)*100, '\n')
cat("minimum richness in sample:", min(diff(inv)), "from sample:", ids[which.min(diff(inv))], '\n')
cat("maximum richness in sample:", max(diff(inv)), "from sample:", ids[which.max(diff(inv))], '\n')

## tax
total.counts <- sum(w)
p.types <- p.counts <- matrix(0, ncol=7, nrow=2)
for (i in 1:7){ 
  p.counts[1,i] <- 1-sum(w[tax[i, ] %in% c('Unassigned', '')])/total.counts 
  p.counts[2,i] <- 1-sum(w[tax[i, ] %in% c('Unassigned', '') | grepl(tax[i, ], pattern='__$')])/total.counts 
}

total.types <- length(w)
for (i in 1:7){ 
  p.types[1,i] <- 1-sum(tax[i,] %in% c('Unassigned', ''))/total.types 
  p.types[2,i] <- 1-sum(tax[i,] %in% c('Unassigned', '') | grepl(tax[i,], pattern='__$'))/total.types 
}

tab <- rbind(p.types, p.counts)*100; 
tabb <- matrix(paste(round(tab, 2), '%'), nrow=4)
colnames(tabb) <- c('Kindom','Phylum','Class','Order','Family','Genus','Species')
rownames(tabb) <- c('type a', 'type b', 'count a', 'count b')

cat("percentage of assigned taxonomy:\n")
tabb

##
cat("percentage of unassigned at Kindom level:", sum(tax[1,]=='Unassigned')/length(w)*100, '\n')
cat("percentage of archaea:", sum(tax[1,]=='k__Archaea')/length(w)*100, '\n')