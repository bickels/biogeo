##### Rarefaction depth

library(rhdf5)

source('./fun/diversity.r')

biom <- './data/biom/taxonomy-raw.biom'
tax <- readRDS('./temp/tax_raw.rds')

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

## null otu
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

v <- apply(otu.full, 2, sum)
w <- apply(otu.full, 1, sum)

## search over rarefaction depths
rarefaction <- seq(2500, 15000, by=2500)
dps <- rep(0, length(rarefaction))
for (i in 1:length(rarefaction)) dps[i] <- sum(v<rarefaction[i])
set.seed(1)
nsim <- 100
cat("searching over rarefaction depths ...\n")
pb <- txtProgressBar(min = 1, max = length(rarefaction), style=3)
div <- array(NA, c(5, length(v), length(rarefaction), nsim))
for (i in 1:length(rarefaction)){
  setTxtProgressBar(pb, i)
  for (j in 1:length(v)){
    if (v[j] >= rarefaction[i]){
      index <- which(otu.full[,j]!=0)
      ct <- otu.full[index, j]
      pool <- rep(index, ct)
      for (k in 1:nsim){
        sampled.species <- table(sample(pool, rarefaction[i], replace=F))
        div[, j,i,k] <- diversity(sampled.species)
      }
    }
  }
}

saveRDS(div, './temp/rarefaction.rds')

# plt1 <- apply(div, c(1,2,3), mean)
# plt2 <- cbind.data.frame(x=rarefaction, y=dps)
