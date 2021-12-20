##### sample description

source('./fun/coords2country.R')
source('./fun/diversity.R')

tab <- readRDS('./temp/rarefied.rds')
df <- readRDS('./temp/df.rds')

## sampling intensity map
quartz('',6, 3)
world <- map_data("world")

tab$cell <- interaction(tab$lon,tab$lat, tab$study, sep='~', drop=T)
tab$counts <- cut(table(tab$cell), breaks=c(0,2,8,100))[match(tab$cell, names(table(tab$cell)))]

plt1 <- cbind.data.frame(tab$cell, tab$counts)
colnames(plt1) <- c('location', 'counts')

## replace missing continents according to google map
df$country <- coords2country(df[, c('lon','lat')])
levels(df$country)[7] <- 'South America'
df[which(is.na(df$country)),c('lat','lon')]

df$country[is.na(df$country)] <- c('South America','South America','Europe','Europe','Europe')

plt2 <- cbind.data.frame(df$D0, df$country, df$BIO)
colnames(plt2) <- c('richness','continent', 'biome')

## samples in continent and biomes
cat("number of samples in different continents: \n")
table(df$country)
cat("percentage of biomes: \n")
round(table(df$BIO)/nrow(df)*100,2)