##### write taxonomy/ci as temporal files 

library(rhdf5)

## main
biom <- './data/biom/taxonomy-cleaned.biom'
tax <- h5read(biom, 'observation/metadata/taxonomy')
saveRDS(tax, file='./temp/tax.rds')

## for asv
biom <- './data/biom/merged.biom'
tax <- h5read(biom, 'observation/metadata/taxonomy')
saveRDS(tax, file='./temp/tax_merged.rds')

## for rarefication
biom <- './data/biom/taxonomy-raw.biom'
tax <- h5read(biom, 'observation/metadata/taxonomy')
saveRDS(tax, file='./temp/tax_raw.rds')
