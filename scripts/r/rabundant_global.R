##### global scale relative abundance

library(mgcv)

source('./fun/unigam_loocv.r')
source('./fun/gam_formula.r')
source('./fun/error.r')

df <- readRDS('./temp/df.rds')
exclude <- c('lon','lat','depth', 'std','BIO', 'study','ID',
             'D1','D2','D_1','D_2','D0',
             'SND','BLD','AWC','PET','ORC')
mtx <- df[, !(names(df) %in% exclude)]
mtx$DRY <- mtx$DRY^-1

## log ratio
mtx <- cbind(log(mtx[, 1:3]/mtx[, 4:6]), mtx); colnames(mtx)[1:3] <- c('X1','X2','X3')

## univariate gam
res <- array(NA, c(2,ncol(mtx)-9, 9))
for (i in 1:9){
  cat('log ratio univariate gam:', i, '/9\n')
  res[,,i] <- unigam_loocv(mat=mtx, index.y=i, index.x=c(10:(ncol(mtx))))
  cat('\n')
}

saveRDS(res,'./temp/res.rds')

## only use the first three columns
m <- t(matrix(paste(round(res[1,,1:3]*100, 1), '%', sep=''), ncol=3))
colnames(m) <- colnames(mtx)[10:ncol(mtx)]