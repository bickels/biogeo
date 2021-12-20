##### prediction: create a map

library(raster)

tabb <- read.delim('./table/prediction.csv', sep=',',stringsAsFactors = F)
# tabb <- readRDS('./temp/prediction.rds')

coordinate <- tabb[, c('x','y')]

## predicted richness
pred <- cbind(coordinate, read.delim('./temp/prediction/predicted.csv', header = F))
colnames(pred) <- c('x','y','Richness')

## R^2
r2 <- read.delim('./temp/prediction/R2.csv', header = F)
r2res <- matrix(r2$V1, nrow=10, ncol=10)
cat('R^2: mean:', mean(apply(r2res, 2, mean)), 'sd:',
    sd(apply(r2res, 2, mean)), '\n')

rmse <- read.delim('./temp/prediction/RMSE.csv', header = F)
rmseres <- matrix(rmse$V1, nrow=10, ncol=10)
cat('RMSE: mean:', mean(apply(rmseres, 2, mean)), 'sd:',
    sd(apply(rmseres, 2, mean)), '\n')

## save 
tif <- pred
coordinates(tif) <- ~x+y
gridded(tif) <- T
rast <- raster(tif)
crs(rast) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

writeRaster(rast, './temp/map.tif', format = "GTiff", overwrite=T)