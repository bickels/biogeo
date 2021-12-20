##### prediction: create a training/testing sets

df <- readRDS('./temp/df.rds')
tabb <- read.delim('./table/prediction.csv', sep=',',stringsAsFactors = F)
# tabb <- readRDS('./temp/prediction.rds')

exclude <- c('lon','lat','depth', 'std','BIO', 'study','ID',
             'D_2','D_1','D1','D2',
             'SND','PET','AWC','BLD', 'ORC', 'A1','A2','A3','R1','R2','R3')
mtx <- df[, !(names(df) %in% exclude)]
mtx$DRY <- mtx$DRY^-1

coordinate <- tabb[, c('x','y')]
tabb <- tabb[,!colnames(tabb) %in% c('x','y','PET','AWC','BLD', 'ORC','SND')]
tabb$DRY <- tabb$DRY^-1

write.table(mtx, './temp/prediction/train.csv', sep=',', col.names = T, row.names = F, quote = F)
write.table(tabb, './temp/prediction/pred.csv',  sep=',', col.names = T, row.names = F, quote=F)