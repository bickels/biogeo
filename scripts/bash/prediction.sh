#!/bin/bash

mkdir -p './temp/prediction'

## split train/test
Rscript './scripts/r/prediction_1.R'

## compute generalization error using nested cv, repeated 10 times
python3 './scripts/python/nested.py'

## make prediction
python3 './scripts/python/prediction.py'

## generate a tiff map
Rscript './scripts/r/prediction_2.R'
