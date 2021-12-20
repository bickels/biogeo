## function to compute R^2 or RMSE

error <- function(test, pred, metric='R2'){
  if (metric=='R2'){
    1-sum((test-pred)^2)/sum((test-mean(test))^2)
  } else if (metric=='RMSE'){
    sqrt(mean((test-pred)^2))
  } else if (mtric=='EXPVAR'){
    1-var(test-pred)/var(test)
  }
}
