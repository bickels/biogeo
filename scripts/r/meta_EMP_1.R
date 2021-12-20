##### EMP: metadata based filtering

library(data.table)

## QIITA REDBIOM: where empo_3=='Soil (non-saline)' or qiita_empo_3=='Soil (non-saline)'
## 60 studies
lst <- list()

path <- './table/accession/EMP/metadata'
for (i in 1:length(list.files(path=path, pattern='.*.txt'))){
  lst[[i]] <- read.delim(list.files(path=path, pattern='.*.txt', full.names = T)[i], sep='\t', header=T, na.string=c('Not applicable', 'Missing: Not provided'))
}
dat <- rbindlist(lst, fill=TRUE)

## soil samples
dat <- dat[which(dat$qiita_empo_3=='Soil (non-saline)' | dat$empo_3=='Soil (non-saline)'),]

## exclude non-representative samples
excluded_study <- c(11154, 1530, ## different link primer
                    1684, 721, 722, 10218, ## meta analysis comparing primer/platforms
                    1674, 1747, 2104, 10442, ## manhatten, zoo, central park, urban
                    10141, 10142, 10143, ## lon-lat in metadata does not correspond to the sampling location -- in cities
                    755, ## sand filter
                    776, 1033, 1035, ## antarctica
                    722, 1024, 10246, 10442) 

dat <- dat[!(dat$qiita_study_id %in% excluded_study),]
dat <- dat[!dat$envo_biome_2 %in% c('anthropogenic terrestrial biome', 'marine biome','freshwater biome'),]
dat <- dat[!dat$country %in% c('GAZ:Antarctica')]
dat <- dat[!dat$env_feature %in% c('ENVO:agricultural soil', 'research facility','oil contaminated soil','compost soil','dry lake', 'extreme high temperature habitat','Oil palm plantation','vineyard', 'rhizosphere')]

dat.emp <- data.frame()

## filtering according to metadata, some filters may be redundant
## if missing depth cannot be found in literature, replace with 0.05
for (i in unique(dat$qiita_study_id)){
  subset <- subset(dat, qiita_study_id==i)
  if (i==632){
    ## Canadian MetaMicroBiome Initiative samples from
    ## https://doi.org/10.4056/sigs.1974654
    exclude <- grep('Compost|garden|Agricultural', subset$X.SampleID)
    subset <- if (length(exclude)==0) subset else subset[-exclude,]
    
  } else if (i==659){
    ## New Zealand Free Air Carbon dioxide Enrichment soil samples
    ## https://doi.org/10.1016/j.soilbio.2013.03.014
    ## filter out CO2 treatment or warming treatment
    subset <- subset[grep('R2.warm|R5.Browntop|R5.control', subset$X.SampleID), ]
    ## 100 mm depth × 50 mm diameter
    subset$depth_m <- 0.05
    
  } else if (i==721){
    ## Global patterns of 16S rRNA diversity at a depth of millions of sequences per sample - 3 prime
    ## https://doi.org/10.1073/pnas.1000080107
    ## drop since same sample in study 722
    subset$depth_m <- 0.025
    
  } else if (i==722){
    ## Global patterns of 16S rRNA diversity at a depth of millions of sequences per sample - 5 prime
    ## https://doi.org/10.1073/pnas.1000080107
    ## upper 5 cm minear soil 
    subset$depth_m <- 0.025
    
  } else if (i==755){
    ## Replicating the microbial community and water quality performance of full-scale slow sand filters in laboratory-scale filters
    ## https://doi.org/10.1016/j.watres.2014.05.008
    ## not natural soil
    
  } else if (i==776){
    ## Jurelivicius Antarctic cleanup
    ## DOI: NA
    ## antarctica soil
    
  } else if (i==805){
    ## Exploring links between pH and bacterial community composition in soils from the Craibstone Experimental Farm
    ## https://doi.org/10.1111/1574-6941.12231
    
  } else if (i==808){
    ## NEON: Directions and resources for long-term monitoring in soil microbial ecology
    ## https://doi.org/10.1890/ES12-00196.1
    
  } else if (i==829){
    ## Environmental metagenomic interrogation of Thar desert microbial communities
    ## https://doi.org/10.1007/s12088-015-0549-1
    ## first 50 mm of soil
    subset$depth_m <- 0.025
    
  } else if (i==846){
    ## Influence of tillage practices on soil microbial diversity and activity in a long-term corn experimental field under continuous maize production
    ## DOI: NA
    ## tillage treatment, no control group exist, use minimum tillage
    subset <- subset[grep('Soil4', subset$X.SampleID), ]
    
  } else if (i==864){
    ## Space, time and change: Investigations of soil bacterial diversity and its drivers in the Mongolian steppe
    ## DOI: NA
    ## warming treatment, watering treatment, vegetation treatment
    subset <- subset[grep('CON.V.2.2009|CON.V.4.2009|CON.V.6.2009', subset$X.SampleID), ]
    
  } else if (i==895){
    ## Kilauea geothermal soils and biofilms
    ## DOI: NA
    
  } else if (i==990){
    ## Spatial scale drives patterns in soil bacterial diversity
    ## https://doi.org/10.1111/1462-2920.13231
    ## Nitrogen addition 67 kg/ha
    subset <- subset[grep('U', subset$X.SampleID), ]
    
  } else if (i==1001){
    ## Understanding Cultivar-Specificity and Soil Determinants of the Cannabis Microbiome
    ## https://doi.org/10.1371/journal.pone.0099641
    ## remove rhizosphere
    subset <-subset[grep('.*[1-3]$', subset$X.SampleID), ]
    ## at a depth of 20 cm
    subset$depth_m <- 0.1
    
  } else if (i==1024){
    ## The Soil Microbiome Influences Grapevine-Associated Microbiota MiSeq
    ## https://doi.org/10.1128/mBio.02527-14.
    ## bulk soil surface samples (depth, 5 to 7 cm)
    subset$depth_m <- 0.06
    ## herbcide addition, but no control, use all
    
  } else if (i==1030){
    ## Spatial variation in arctic soil microbial communities in fire impacted permafrost ecosystems
    ## https://doi.org/10.1038/ismej.2014.36
    subset <-subset[grep('Control', subset$X.SampleID), ]
    subset <-subset[grep('D10', subset$X.SampleID), ]
    
  } else if (i==1031){
    ## Myrold Alder Fir
    ## https://doi.org/10.1007/s00248-010-9675-9
    
  } else if (i==1033){
    ## Brazilian contaminated antarctic soils
    ## DOI: NA
    ## antarctica soil
    
  } else if (i==1034){
    ## Distinct microbial communities associated with buried soils in the Siberian tundra
    ## https://doi.org/10.1038/ismej.2013.219
    ## only use samples that do not miss depth
    subset <- subset[!is.na(subset$depth_m),]
    
  } else if (i==1035){
    ## The ecological dichotomy of ammonia-oxidizing archaea and bacteria in the hyper-arid soils of the Antarctic Dry Valleys (NZTABS)
    ## https://doi.org/10.3389/fmicb.2014.00515
    ## antarctica soil
    
  } else if (i==1036){
    ## Microbial communities of the deep unfrozen: Do microbes in taliks increase permafrost carbon vulnerability?
    ## https://doi.org/10.1038/ismej.2011.163
    ## only use samples that do not miss depth
    subset <- subset[!is.na(subset$depth_m),]
    
  } else if (i==1037){
    ## Long Term Soil Productivity project
    ## https://doi.org/10.1038/ismej.2015.57
    ## no harvesting occurred (OM0), stem-only harvesting, leaving behind the crowns and branches (OM1), whole-tree harvesting (OM2) and whole-tree harvesting plus removal of the forest floor (organic soil layer; OM3)
    ## top 20 cm of the mineral layer (organic layer: forest floor, above ground those removed)
    subset <- subset[grep('REF.MIN', subset$X.SampleID), ]
    subset$depth_m <- 0.1
    
  } else if (i==1038){
    ## Myrold Oregon transect
    ## DOI: NA
    
  } else if (i==1043){
    ## Laboratory Directed Research and Development Biological Carbon Sequestration
    ## DOI: NA
    subset <- subset[grep('Control', subset$X.SampleID), ]
    
  } else if (i==1289){
    ## Temple TX native exotic precip study
    ## DOI: NA
    ## non irrigation / native
    subset <- subset[subset$X.SampleID %in% paste('1289.KH', 50:65, sep=''), ]
    
  } else if (i==1521){
    ## Samples presented at EMP conference June 2011 Shenzhen
    ## DOI: NA
    ## antarctica soil
    exclude <- grep(paste(paste('1521.EB0', 17:26, sep=''), collapse='|'), subset$X.SampleID)
    subset <- if (length(exclude)==0) subset else subset[-exclude,]
    ## potential duplicates
    exclude <- grep('s.8.1', subset$X.SampleID)
    subset <- if (length(exclude)==0) subset else subset[-exclude,]
    ## replace depth
    subset$depth_m <- 0.025
    
  } else if (i==1526){
    ## Recovery of biological soil crust-like microbial communities in previously submerged soils of Glen canyon
    ## DOI: NA
    ## 0-0.05 m depth, remove missing latitude
    subset$depth_m <- 0.025
    subset <- subset[grep('CrustControl', subset$X.SampleID), ]
    
  } else if (i==1530){
    ## Impact of fire on active layer and permafrost microbial communities and metagenomes in an upland Alaskan boreal forest
    ## https://doi.org/10.1038/ismej.2014.36
    ## control groups ## depth need to be changed manually
    subset <- subset[grep('NC.C.U', subset$X.SampleID),]
    dpth <- paste('D', 1:10, sep='')
    for (i in 1:length(dpth)){
      subset[grep(dpth[i], subset$X.SampleID),]$depth_m <- i/10-0.05
    }
    
  } else if (i==1578){
    ## Changes in microbial communities along redox gradients in polygonized Arctic wet tundra soils
    ## https://doi.org/10.1111/1758-2229.12301
    
  } else if (i==1579){
    ## Hawaii Kohala Volcanic Soils
    ## DOI: NA
    exclude <- grep('ORG', subset$X.SampleID)
    subset <- if (length(exclude)==0) subset else subset[-exclude,]
    
  } else if (i==1642){
    ## Microbial community of the bulk soil and rhizosphere of rice plants over its lifecycle
    ## DOI: NA
    ## cropland, pesticide used, no control group
    ## depth unknown
    subset$depth_m <- 0.05
    
  } else if (i==1674){
    ## Urban stress is associated with variation in microbial species composition—but not richness—in Manhattan
    ## https://doi.org/10.1038/ismej.2015.152
    ## five soil cores (0 to 10 cm) were composited as a representative sample for each plot
    subset$depth_m <- 0.05
    ## manhattan
    
  } else if (i==1684){
    ## Ultra-high-throughput microbial community analysis on the Illumina HiSeq and MiSeq platforms (MiSeq)
    ## https://doi.org/10.1038/ismej.2012.8
    ## unknown depth
    subset$depth_m <- 0.05
    
  } else if (i==1692){
    ## Friedman Alaska peat soils
    ## https://doi.org/10.3390/min3030318
    ## remove biomfile
    exclude <- grep('Biofilm|BE', subset$X.SampleID)
    subset <- if (length(exclude)==0) subset else subset[-exclude,]
    
  }else if (i==1702){
    ## Chu Changbai mountain soil
    ## https://doi.org/10.1016/j.soilbio.2012.07.013
    ## 0–5 cm depth directly below the litter layer
    
  } else if (i==1711){
    ## Agricultural intensification and the functional capacity of soil microbes on smallholder African farms - kakamenga
    ## DOI: NA
    ## top 20 cm of bulk soil, cannot identify which plot is the control
    subset$depth_m <- 0.1
    
  } else if (i==1713){
    ## Malaysia Lambir Soils
    ## DOI: NA
    
  } else if (i==1714){
    ## Malaysia Pasoh Landuse Logged Forest
    ## https://doi.org/10.1007/s00248-014-0468-4
    
  } else if (i==1715){
    ## McGuire Nicaragua coffee soil
    ## DOI: NA
    
  } else if (i==1716){
    ## Panama Precip Grad Soil
    ## https://doi.org/10.1007/s00248-011-9973-x
    ## From each plot, 15 composite soil cores (0–20 cm)
    
  } else if (i==1717){
    ## Agricultural intensification and the functional capacity of soil microbes on smallholder African farms -swkenya 
    ## https://doi.org/10.1111/1365-2664.12416
    ## top 20 cm of bulk soil, fertilizer treatment
    ## experiment plot
    subset <- subset[grep('KBC14.experimental|KBC19.experimental|KBC2.experimental|KBC8.experimental', subset$X.SampleID),]
    subset$depth_m <- 0.1
    
  }else if (i==1721){
    ## A combination of biochar-mineral complexes and compost improves soil bacterial processes, soil quality, and plant properties
    ## https://doi.org/10.1016/j.agee.2014.04.006
    ## 0–100 mm, biochar treatment
    subset <- subset[grep('SB', subset$X.SampleID),]
    subset$depth_m <- 0.05
    
  } else if (i==1747){
    ## The oral and skin microbiomes of captive Komodo Dragons are significantly shared with their habitat
    ## https://doi.org/10.1128/mSystems.00046-16
    ## sampled in zoo
    subset$depth_m <- 0.05
    
  } else if (i==1883){
    ## Microbial diversity in arctic freshwaters is structured by inoculation of microbes from soil
    ## https://doi.org/10.1038/ismej.2012.9
    ## sampled from soil water 
    ## samples were pooled from 5–10 randomly chosen locations of depths between 5 and 20 cm.
    subset$depth_m <- 0.125
    
  } else if (i==2104){
    ## Biogeographic patterns in below-ground diversity in New York City s Central Park are similar to those observed globally 16S
    ## https://doi.org/10.1098/rspb.2014.1988
    ## 5 cm 
    subset$depth_m <- 0.025
    
  } else if (i==2382){
    ## The Soil Microbiome Influences Grapevine-Associated Microbiota HiSeq
    ## https://doi.org/10.1128/mBio.02527-14
    ## bulk soil surface samples (depth, 5 to 7 cm), remove rhi and root
    subset <- subset[grep('bulk', subset$X.SampleID),]
    subset$depth_m <- 0.06
    
  } else if (i==10082){
    ## Effects of Management, Soil Attributes and Region on Soil Microbial Communities in Vineyards (Napa, California, USA)
    ## https://doi.org/10.1016/j.soilbio.2015.09.002
    ## at a depth of 0–5 cm
    subset$depth_m <- 0.025
    ## sieved and air dried
    exclude <- grep('m', subset$X.SampleID)
    subset <- if (length(exclude)==0) subset else subset[-exclude,]
    ## management difference, no tillage, no compost
    subset <- subset[grep('02|07|15|16|18', subset$X.SampleID),]
    
  } else if (i==10141){
    ## Metcalf Microbial community assembly and metabolic function during mammalian corpse decomposition Mouse exp
    ## https://doi.org/10.1126/science.aad2646
    subset <- subset[grep('CTRL', subset$X.SampleID),]
    ## 0-10cm
    subset$depth_m <- 0.05
    
  } else if (i==10142){
    ## Metcalf Microbial community assembly and metabolic function during mammalian corpse decomposition SHSU winter
    ## https://doi.org/10.1126/science.aad2646
    subset <- subset[grep('ctrl', subset$X.SampleID),]
    ## 0-10cm
    subset$depth_m <- 0.05
    
  }else if (i==10143){
    ## Metcalf Microbial community assembly and metabolic function during mammalian corpse decomposition SHSU April 2012 exp	
    ## https://doi.org/10.1126/science.aad2646
    subset <- subset[grep('ctrl', subset$X.SampleID),]
    ## 0-10cm
    subset$depth_m <- 0.05
    
  } else if (i==10145){
    ## Beach sand microbiome from Calvert Island Canada
    ## DOI: NA
    ## beach sand
    subset <- subset[grep('SO', subset$X.SampleID), ]
    
  } else if (i==10156){
    ## The effect of wetland age and restoration methodology on long term development and ecosystem functions of restored wetlands
    ## wetland
    ## DOI: NA
    subset$depth_m <- 0.05
    ## control group
    subset <- subset[grep('1C|2C|3C|4C', subset$X.SampleID),]
    ## subset <- subset[subset$X.SampleID %in% paste('10156.', 1:56, sep=''),]
    ## wetland
    
  } else if (i==10180){
    ## Metagenome of microbial communities involved in the nitrogen cycle in sugarcane soils in Brazil
    ## DOI: NA (http://www.teses.usp.br/teses/disponiveis/11/11138/tde-28112016-175102/pt-br.php)
    ## 0-20 cm
    subset$depth_m <- 0.1
    ## without burning, activated carbon, fertilizer
    subset <- subset[grep('F10|F3|F7|F9|G6|G8', subset$X.SampleID),]
    
  } else if (i==10218){
    ## Improved Bacterial 16S rRNA Gene (V4 and V4-5) and Fungal Internal Transcribed Spacer Marker Gene Primers for Microbial Community Surveys
    ## https://doi.org/10.1128/mSystems.00009-15
    ## to a depth of 5 cm
    subset$depth_m <- 0.025
    ## only use one soil argi. soil, the rhizosphere is not considered, the decomposition is already taken 
    subset <- subset[grep('T1|T7', subset$X.SampleID), ]
    
  } else if (i==10246){
    ## The North American Arctic Transect, NAAT and the Eurasian Arctic Transect, EAT
    ## https://doi.org/10.1111/mec.12743 
    ## each soil core included organic and mineral horizonsfrom the upper 5–10 cm
    subset$depth_m <- 0.075
    
  } else if (i==10360){
    ## Arid Soil Microbiome: Significant Impacts of Increasing Aridity
    ## https://doi.org/10.1128/mSystems.00195-16
    ## depth does't matter for mapping to soilgrid -- 0.01, 0.02, 0.03 equivalent
    subset$depth_m <- 0.02
    
  } else if (i==10363){
    ## Investigating the rhizosphere microbiome as influenced by soil selenium, plant species, plant selenium accumulation and geographic proximity
    ## https://doi.org/10.1111/nph.13164
    ## from 0 to 10 cm depth 
    subset$depth_m <- 0.05
    
    
  } else if (i==10431){
    ## Effect of anaerobic soil disinfestation on soilborne phytopathogenic agents and bacterial community under walnut tree-crop nursery conditions
    ## control group of trial 1 and 2
    ## DOI: NA
    subset <- subset[grep(paste(paste('10431.E', c(2,4,10,11,12,13,15), sep=''), collapse='|'), subset$X.SampleID),]
    subset$depth_m <- 0.152
    depthidx <- sub('^.*\\.', '', subset$X.SampleID)
    subset$depth_m[depthidx==18] <- 0.457
    subset$depth_m[depthidx==30] <- 0.762
    
  } else if (i==10442){
    ## Free-Living Amoeba Reservoirs of Pathogenic Leptospira 
    ## DOI: NA
    ## urban metagenome
    
  } else if (i==11154){
    ## Copolymers enhance selective bacterial community colonization for potential root zone applications
    ## https://doi.org/10.1038/s41598-017-16253-0
    ## 0–10 cm
    subset$depth_m <- 0.05
    subset <- subset[grep('36|37|38|39|40', subset$X.SampleID),]
    ## different primer set
  }
  subset <- subset[subset$depth_m<=0.1,]
  dat.emp <- rbind(dat.emp, subset)
}

dat.emp <- dat.emp[, c('X.SampleID', 'longitude', 'latitude', 'depth_m')]; colnames(dat.emp) <- c('ID','lon','lat','depth');
dat.emp$study <- 'EMP'

## search which sample are open
lst <- list()
path <- './table/accession/EMP/ERX'
for (i in 1:length(list.files(path=path, pattern='.*.tsv'))){
  lst[[i]] <- read.delim(list.files(path=path, pattern='.*.tsv', full.names = T)[i], sep='\t', header=T, na.strings = 'None')
}
ERX <- rbindlist(lst, fill=TRUE)
ERX <- na.omit(ERX)
dat.emp <- dat.emp[dat.emp$ID %in% ERX$sample_name, ]

## write a metadata file
write.table(dat.emp, './data/EMP/meta_emp.csv', row.names = F, quote=F, sep=',')

## write a file for ERX
ERX <- ERX[ERX$sample_name %in% dat.emp$ID,]
write.table(ERX$experiment_accession, './data/EMP/ERX.txt', sep=',', col.names = F, row.names = F, quote = F)
