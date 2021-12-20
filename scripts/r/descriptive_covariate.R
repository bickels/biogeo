##### covariates description

df <- readRDS('./temp/df.rds')

## only consider covariates
exclude <- c('lon','lat','depth','std', 'study','BIO',
             'D_2','D_1','D1','D2','A1','A2','A3','R1','R2','R2','R3','D0')
mtx <- df[, !(names(df) %in% exclude)]

## change the order
mtx <- mtx[, c('SLT','SND','PH','DRY','MAP','NPP','CLY','RAD','MAT','PET','CEC','ORC','CWC','BLD','AWC'),]
coll <- !names(mtx) %in% c('ORC','SND','PET','AWC','BLD')

## correlation matrix
corr <- local <-  cor(mtx, method='spearman')

# ## merge clusters
d <- as.dist(1-abs(corr))
clust <- hclust(d, method='average')
dend <- as.dendrogram(clust)
