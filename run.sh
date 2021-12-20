#!/bin/bash

## download data
bash './scripts/bash/download_EMBL.sh'
bash './scripts/bash/download_ZHOU.sh'
bash './scripts/bash/download_EMP.sh'

## train classifier
bash './scripts/bash/train_classifier.sh'

## preprocessing
bash './scripts/bash/preprocess_EMBL.sh'
bash './scripts/bash/preprocess_ZHOU.sh'
bash './scripts/bash/preprocess_EMP.sh'

bash './scripts/bash/merge_studies.sh' 

## extract covariates
# Rscript './scripts_unused/rasterize_biom.R'
# Rscript './scripts_unused/preprocess_covariates.R'

## generate BIOM table and compute diversity
bash './scripts/bash/filter_biom.sh'
Rscript './scripts/r/preprocess_biom.R'

## descriptive
Rscript './scripts/r/descriptive_asv.R'
Rscript './scripts/r/descriptive_rarefaction.R'
Rscript './scripts/r/descriptive_sample.R'
Rscript './scripts/r/descriptive_covariate.R'

## run univariate GAM
Rscript './scripts/r/inference_univariate.R'

## run multivariate GAM
Rscript './scripts/r/inference_multivaraite.R'

## run CAM
Rscript './scripts/r/inference_causal.R'

## run rare/abundant models
Rscript './scripts/r/rabundant_global.R'
Rscript './scripts/r/rabundant_local.R'

## run prediction
bash './scripts/bash/prediction.sh'
