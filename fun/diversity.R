## compute diversity indices

diversity <- function (sample.vec) {
  p <- sample.vec/sum(sample.vec)
  d_1 <- sum(p^-1)^(1/(1+1))
  d_2 <- sum(p^-2)^(1/(1+2))
  d0 <- sum(sample.vec > 0)
  d1 <- exp(-sum(p * log(p)))
  d2 <- 1/(sum(p^2))
  d <- cbind(d_2, d_1, d0, d1, d2)
  return(d)
}