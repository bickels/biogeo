##### causal additive model

library(CAM)

source('./fun/gam_formula.R')

df <- readRDS('./temp/df.rds')
exclude <- c('lon','lat','depth','std', 'study','BIO',
             'D_2','D_1','D1','D2',
             'SND', 'A1','A2','A3','R1','R2','R3')

mtx <- df[, !(names(df) %in% exclude)]
mtx$DRY <- mtx$DRY^-1

## multi split
set.seed(1)
sim <- 100
p <- array(1, c(ncol(mtx), ncol(mtx), sim))

pb <- txtProgressBar(min = 1, max = sim, style=3)
for (j in 1:sim){
  setTxtProgressBar(pb, j)
  idxx <- sample(1:nrow(mtx), nrow(mtx)/2)
  train <- mtx[idxx,]
  test <- mtx[-idxx,]
  
  fit <- CAM(as.matrix(train), output = F, variableSelMethod = selGamBoost,
             scoreName='SEMGAM', pruning=F, variableSel = F, numCores = 1)
  
  # qgraph(fit$Adj, layout='circle', labels=colnames(mtx))
  
  for (y in 1:ncol(test)){
    x <- which(fit$Adj[, y]!=0)
    if (length(x)!=0) {
      p[x, y, j] <- summary(gam(gam_formula(test, y, x, pred=F), method = 'REML'))$s.pv
    }
  }
}

## adj p-value by cardinality of selected covariates
padj <- array(1, c(ncol(test), ncol(test), sim))
for (i in 1:sim){
  for (j in 1:ncol(test)){
    S <- sum(p[,j,i]!=1)
    temp <- if (S!=0) S * p[,j,i] else p[,j,i]
    padj[,j,i] <- temp
  }
}

gamma <- seq(0.05, 1, by=0.025)

## compute quantile adjusted and aggregated
adjmat <- matrix(0, ncol(test), ncol(test))
for (i in 1:ncol(test)){
  for (j in 1:ncol(test)){
    q <- quantile(padj[i,j,], gamma)/gamma*(1-log(0.05))
    adjmat[i,j] <- min(q)
  }
}

saveRDS(adjmat, './temp/causal.rds')

## cutoff, ph is directed to D0 if p=0.05
fmat <- adjmat<=0.0005
