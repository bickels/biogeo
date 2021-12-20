## leave one out cv for univariate gam

multigam_loocv <- function(index.y, index.x, mat){
  res <- array(NA, c(nrow(mat)))
  pb <- txtProgressBar(min = 1, max =nrow(mat), style=3)
  for(i in 1:nrow(mat)){
    setTxtProgressBar(pb, i)
    fit <- gam(gam_formula(mat, index.y, index.x), data=mat[-i, ], method='REML', select=T)
    res[i] <- predict(fit, mat[i, ])
  }
  r2 <- error(mat[,index.y], res , metric='R2')
  rmse <- error(mat[, index.y], res, metric='RMSE')
  return(rbind(r2, rmse))
}