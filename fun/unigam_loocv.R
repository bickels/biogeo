## leave one out cv for univariate gam

unigam_loocv <- function(index.y, index.x, mat){
  rs <- array(NA, c(length(index.x), nrow(mat)))
  pb <- txtProgressBar(min = 1, max =nrow(mat), style=3)
  for(i in 1:nrow(mat)){
    setTxtProgressBar(pb, i)
    for (j in 1:length(index.x)){
      fit <- gam(gam_formula(mat, index.y, index.x[j]), data=mat[-i,], method='REML')
      rs[j,i] <- predict(fit, mat[i,])
    }
  }
  r2 <- apply(rs, 1, function(x) error(mat[,index.y], x , metric='R2'))
  rmse <- apply(rs, 1, function(x) error(mat[, index.y], x, metric='RMSE'))
  return(rbind(r2, rmse))
}