##### multivaraite modeling

library(mgcv)

source('./fun/gam_formula.r')
source('./fun/multigam_loocv.r')
source('./fun/error.r')

df <- readRDS('./temp/df.rds')
exclude <- c('lon','lat','depth', 'std','BIO', 'study','ID',
            'SND','BLD','AWC','PET','ORC','D_2','D_1','D1','D2','A1','A2','A3','R1','R2','R3')
mtx <- df[, !(names(df) %in% exclude)]
mtx$DRY <- mtx$DRY^-1

## forward selection, conditioning on the estimated smoothing paramter
## CWC has the lowest AIC
fit0 <- gam(D0~1, data=mtx, method='REML')
var <- colnames(mtx)[!colnames(mtx) %in% c('D0')]
aic <- rep(NA, length(var)); names(aic) <- var
for (i in 1:length(var)){
  aic[i]<- AIC(gam(as.formula(paste('D0~s(',var[i],')')), data=mtx, method='REML'))
}
# aic-AIC(fit0)

## PH second
fit1 <- gam(D0~s(CWC), data=mtx, method='REML')
var <- colnames(mtx)[!colnames(mtx) %in% c('D0', 'CWC')]
aic <- rep(NA, length(var)); names(aic) <- var
for (i in 1:length(var)){
  aic[i]<- AIC(gam(as.formula(paste('D0~s(CWC,sp=',fit1$sp,')+s(',var[i],')')), data=mtx, method='REML'))
}
# aic-AIC(fit1)

## MAT
fit2 <- gam(D0~s(CWC, sp=fit1$sp)+s(PH), data=mtx, method='REML')
var <- colnames(mtx)[!colnames(mtx) %in% c('D0', 'CWC', 'PH')]
aic <- rep(NA, length(var)); names(aic) <- var
for (i in 1:length(var)){
  aic[i]<- AIC(gam(as.formula(paste('D0~s(CWC,sp=',fit1$sp,')+s(PH,sp=',fit2$sp,')+s(',var[i],')')), data=mtx, method='REML'))
}
# aic-AIC(fit2)

##
fit3 <- gam(D0~s(CWC, sp=fit1$sp)+s(PH, sp=fit2$sp)+s(MAT), data=mtx, method='REML')
var <- colnames(mtx)[!colnames(mtx) %in% c('D0', 'CWC', 'PH','MAT')]
aic <- rep(NA, length(var)); names(aic) <- var
for (i in 1:length(var)){
  aic[i]<- AIC(gam(as.formula(paste('D0~s(CWC,sp=',fit1$sp,')+s(PH,sp=',fit2$sp,')+s(MAT,sp=',fit3$sp,')+s(',var[i],')')), data=mtx, method='REML'))
}
# aic-AIC(fit3)

##
fit4 <- gam(D0~s(CWC, sp=fit1$sp)+s(PH, sp=fit2$sp)+s(MAT, sp=fit3$sp)+s(SLT), data=mtx, method='REML')
var <- colnames(mtx)[!colnames(mtx) %in% c('D0', 'CWC', 'PH','MAT', 'SLT')]
aic <- rep(NA, length(var)); names(aic) <- var
for (i in 1:length(var)){
  aic[i]<- AIC(gam(as.formula(paste('D0~s(CWC,sp=',fit1$sp,')+s(PH,sp=',fit2$sp,')+s(MAT,sp=',fit3$sp,')+s(SLT,sp=',fit4$sp,')+s(',var[i],')')), data=mtx, method='REML'))
}
# aic-AIC(fit4)

##
fit5 <- gam(D0~s(CWC, sp=fit1$sp)+s(PH, sp=fit2$sp)+s(MAT, sp=fit3$sp)+s(SLT, sp=fit4$sp)+ s(DRY), data=mtx, method='REML')
var <- colnames(mtx)[!colnames(mtx) %in% c('D0', 'CWC', 'PH','MAT', 'SLT','DRY')]
aic <- rep(NA, length(var)); names(aic) <- var
for (i in 1:length(var)){
  aic[i]<- AIC(gam(as.formula(paste('D0~s(CWC,sp=',fit1$sp,')+s(PH,sp=',fit2$sp,')+s(MAT,sp=',fit3$sp,')+s(SLT,sp=',fit4$sp,')+s(DRY,sp=',fit5$sp,')+s(',var[i],')')), data=mtx, method='REML'))
}
# aic-AIC(fit5)

##
fit6 <- gam(D0~s(CWC, sp=fit1$sp)+s(PH, sp=fit2$sp)+s(MAT, sp=fit3$sp)+s(SLT, sp=fit4$sp)+ s(DRY, sp=fit5$sp)+s(CEC), data=mtx, method='REML')

## ANOVA LR xi^2 approximation text
anova(fit0, fit1, fit2, fit3, fit4, fit5,fit6, test = 'Chisq')
aic <- round(diff(AIC(fit0, fit1, fit2, fit3,fit4,fit5,fit6)[,2]),2)
names(aic) <- c('CWC','PH','MAT','SLT','DRY','CEC')

## delta AIC
cat('delta AIC: \n')
aic

## gam with shrinkage
fit <- gam(gam_formula(mtx, 1, 2:ncol(mtx)), data=mtx, method='REML', select=T)
s <- summary(fit)

## loocv R2 gam with shrinkage
cat("loocv for multivariate gam ... \n")
err <- multigam_loocv(1, 2:ncol(mtx), mat=mtx)
saveRDS(err, './temp/err.rds')
