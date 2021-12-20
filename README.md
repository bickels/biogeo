# Global soil bacterial biogeography

Code accomodating the paper: *"A hierarchy of environmental covariates control the global biogeography of soil bacterial richness"* by Samuel Bickel, Xi Chen, Andreas Papritz and Dani Or. 

Original code provided by Xi Chen (xiche@student.ethz.ch)

Correspondence to: Samuel Bickel (samuel.bickel@usys.ethz.ch)

Affiliation: Soil, Terrestrial and Environmental Physics (STEP); Institute of Biogeochemistry and Pollutant dynamics (IBP); Swiss Federal Institute of Technology (ETH), Zürich

---
## System requirements

### Tested on: 
OSX 64bit

### Dependencies (tested version):
- Qiime2 (2018.8)
- Qiime1 (1.9.1)
- Deblur (1.1.0)
- cutadapt (1.18)
- Python (3.5.6)
	- scikit-learn (0.19.1)
	- numpy (1.13.0)
	- pandas (0.21.0)
- R (3.5.0)
	- mgcv (R package for GAM, 1.8-24)
	- CAM (R package for CAM, 1.0)
	- rhdf5 (2.24.0)
	- raster (2.8-19)
	- data.table (1.11.6)

## Installation
Once dependencies are installed the bash script (`run.sh`) can be executed from the command line:
```bash
$ ./run.sh
```
Installation should be possible within less than 30min. Runtime depends on the resources available (~24h) on a standard laptop (if parallelized).

## issue
file "prediction.csv" too large (200+ MB)
