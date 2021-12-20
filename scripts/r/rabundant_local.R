##### local scale relative abundance

library(mgcv)

source('./fun/unigam_loocv.r')
source('./fun/multigam_loocv.r')
source('./fun/gam_formula.r')
source('./fun/error.r')

df <- readRDS('./temp/df.rds')
exclude <- c('lon','lat','depth', 'std','BIO', 'study','ID',
             'A1','A2','A3','R1','R2','R3',
             'SND','BLD','AWC','PET','ORC')
mtx <- df[, !(names(df) %in% exclude)]
mtx$DRY <- mtx$DRY^-1

ress <- array(NA, c(2,ncol(mtx)-5, 5))
for (i in 1:5){
  cat('diversity indices univariate gam:', i, '/5\n')
  ress[,,i] <- unigam_loocv(mat=mtx, index.y=i, index.x=c(6:(ncol(mtx))))
  cat('\n')
}

saveRDS(ress, './temp/ress.rds')

m <- t(matrix(paste(round(ress[1,,]*100, 1), '%', sep=''), ncol=5))
colnames(m) <- colnames(mtx)[6:ncol(mtx)]

resm <- array(NA, c(2, 5))
for (i in 1:5){
  cat('diversity indices multivariate gam:', i, '/5\n')
  resm[,i] <- multigam_loocv(mat=mtx, index.y=i, index.x=c(6:(ncol(mtx))))
  cat('\n')
}

saveRDS(resm, './temp/resm.rds')
