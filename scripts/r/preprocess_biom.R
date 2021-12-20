##### BIOM preprocessing

library(rhdf5)

source('./fun/diversity.R')

dir.create("./temp/prediction", recursive =T, showWarnings=F)

tabb <- read.delim('./table/covariates.csv', sep=',',stringsAsFactors = F)
# tabb <- readRDS('./temp/covariates.rds')
tax <- readRDS('./temp/tax.rds')
taxx <- apply(tax, 2, function(x) paste(x, collapse='~'))
saveRDS(taxx, './temp/taxx.rds')

biom <- './data/biom/taxonomy-cleaned.biom'

## count of species
dat <- h5read(biom, '/sample/matrix/data')
## indices of species, first one is 0
indices <- h5read(biom, '/sample/matrix/indices') +1
## interval between studies, first one is 0
inv <- h5read(biom, '/sample/matrix/indptr') +1
## study id
ids <- h5read(biom, '/sample/ids')
s <- intersect(ids, tabb$ID)
df <- tabb[tabb$ID %in% s, ]

su <- h5ls(biom)
num.species <- max(indices)
H5close()

## full otu table
num <- match(df$ID, ids)

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

saveRDS(otu.full, './temp/otu.rds')

## get row sum and column sum
v <- apply(otu.full, 2, sum)
w <- apply(otu.full, 1, sum)

## compute richness, averaged over 100 rarefied samples
cat("compute diversity, averaged over 100 rarefied samples ...\n")
set.seed(1)
otu.super <- matrix(0, ncol=ncol(otu.full), nrow=nrow(otu.full))
nsim=100
div <- array(0, c(5, ncol(otu.full), nsim))
rarefaction <- 7500
pb <- txtProgressBar(min = 1, max = ncol(otu.full), style=3)
for (i in 1:ncol(otu.full)){
  setTxtProgressBar(pb, i)
  if (sum(otu.full[,i]) >= rarefaction){
    index <- which(otu.full[,i]!=0)
    ct <- otu.full[index, i]
    pool <- rep(index, ct)
    for (k in 1:nsim){
      sampled.species <- table(sample(pool, rarefaction, replace=F))
      otu.super[as.numeric(names(sampled.species)), i] <- otu.super[as.numeric(names(sampled.species)), i] +  sampled.species
      div[, i,k] <- diversity(sampled.species)
    }
  }
}

## rare/abundance species, need longer time
cat("compute diversity for rare/abundant species, takes much longer time ...\n")
set.seed(1)
nsim=100
rarefaction <- 7500
seq <- round(c(0.000005, 0.00005, 0.0005)*sum(w))
div.org <- array(NA, c(ncol(otu.full),2*length(seq), nsim))
pb <- txtProgressBar(min = 1, max = ncol(otu.full), style=3)
for (i in 1:ncol(otu.full)){
  setTxtProgressBar(pb, i)
  index <- which(otu.full[,i]!=0)
  ct <- otu.full[index, i]
  pool <- rep(index, ct)
  for (k in 1:nsim){
    sampled.species <- table(sample(pool, rarefaction, replace=F))
    ## for consistency with previous results the for loop is not modified, but it takes too much time
    ## and should be moved outside the main loop
    for (l in 1:length(seq)){
      div.org[i,l,k] <- sum(names(sampled.species) %in% which(w<=seq[l]))
      div.org[i, l+length(seq), k] <- sum(names(sampled.species) %in% which(w>seq[l]))
    }
  }
}

saveRDS(div,'./temp/div.rds')
saveRDS(div.org,'./temp/div.org.rds')

## aggregate over lon/lat 0.1 degree
index <- interaction(ceiling(df$lon/0.1)*0.1-0.05, ceiling(df$lat/0.1)*0.1-0.05,df$study, sep='~', drop=T)
lgh <- unique(index)
otu.small <- matrix(0, nrow=num.species, ncol=length(lgh))
colnames(otu.small) <- lgh

## create an aggregated otu table
cat("aggregate over geographical location ...\n")
pb <- txtProgressBar(min = 1, max = length(lgh), style=3)
for (i in 1:length(lgh)){
  setTxtProgressBar(pb, i)
  subset <- which(index %in% lgh[i])
  if (length(subset)>1){
    otu.small[, i] <- apply(otu.super[, subset], 1, mean)
  } else {
    otu.small[, i] <- otu.super[, subset]
  }
}

saveRDS(otu.small, './temp/otu.small.rds')

## aggregate all covaraites
D0 <- t(apply(div, c(1,2), mean))
org <- apply(div.org, c(1,2), mean)
dff <- cbind(D0, org, df)
colnames(dff)[1:(ncol(D0)+ncol(org))] <- c('D_2', 'D_1','D0','D1', 'D2', 'R1','R2','R3','A1','A2','A3')
saveRDS(dff, './temp/rarefied.rds')
temp <- cbind(dff$ID, dff[, -12])
colnames(temp)[1] <- 'ID'
write.table(temp, './table/diversity.csv', sep=',', row.names = F, quote = F)

## compute the mean/majority
dff$cellcell <- index
dff_mean <- aggregate(dff[, !colnames(dff) %in% c('ID','study', 'cellcell','BIO')], list(dff$cellcell), mean)
dff_std <- aggregate(dff$D0, list(dff$cellcell), sd)
dff_std$x[is.na(dff_std$x)] <- 0
dff_study <- aggregate(dff$study, list(dff$cellcell), function(x) names(which.max(table(x))))
dff_bio <- aggregate(dff$BIO, list(dff$cellcell), function(x) as.numeric(names(which.max(table(x, useNA='ifany')))))
dfff <- cbind(dff_mean[, -1], dff_std[,-1], dff_bio[,-1], dff_study[,-1])
colnames(dfff)[(ncol(dfff)-2):ncol(dfff)] <- c('std','BIO','study')

## relabel biom
labels <- c('Tropical Forests','Tropical Forests','Tropical Forests','Temperate Forests','Temperate Forests',
            'Boreal Forests','Tropical Grasslands','Temperate Grasslands','Others','Montane Grasslands',
            'Tundra','Mediterranean','Deserts','Others', 'Others')

levels <- c('Deserts', 'Tropical Forests','Tropical Grasslands', 'Temperate Forests',
            'Temperate Grasslands','Mediterranean','Montane Grasslands','Boreal Forests',
            'Tundra','Others')

dfff$BIO <- factor(dfff$BIO, labels=labels); dfff$BIO <- factor(dfff$BIO, levels=levels)

saveRDS(dfff, './temp/df.rds')
write.table(dfff, './table/diversity_aggregated.csv', sep=',', row.names = F, quote = F)
