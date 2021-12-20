##### univariate modeling

library(mgcv)

source('./fun/gam_formula.r')
source('./fun/unigam_loocv.r')
source('./fun/error.r')

df <- readRDS('./temp/df.rds')

## only consider richness D0
exclude <- c('lon','lat','depth', 'std','BIO', 'study','ID',
             'D_1','D_2','D1','D2',
            'SND','BLD','AWC','PET','ORC','A1','A2','A3','R1','R2','R3')
mtx <- df[, !(names(df) %in% exclude)]
mtx$DRY <- mtx$DRY^-1

## AIC and EDF
rst <- array(NA, c(2, ncol(mtx)-1))
for (j in 2:ncol(mtx)){
  ss <- summary(fit <- gam(mtx[,1]~s(mtx[,j]), method='REML'))
  rst[1,j-1] <- AIC(fit)
  rst[2,j-1] <- ss$edf
}

## RMSE and R2
cat("loocv for univariate gam ... \n")
res <- unigam_loocv(mat=mtx, index.y=1, index.x=c(2:(ncol(mtx))))

mta <- rbind(res, rst); colnames(mta) <- colnames(mtx)[2:ncol(mtx)]; rownames(mta) <- c('R2','rmse','AIC','edf')
mta

## check the correlation between ph and cwc
fit <- gam(mtx$PH~s(mtx$CWC), method='REML')