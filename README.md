# Master Thesis Repository
 This repository contains all relevant scripts used for the Master Thesis: 

**Evaluating the performance of remotely sensed soil moisture products on peatlands in the Netherlands and the impact of soil moisture on carbon fluxes**

*External Supervisor:* M.Sc. Laurent Bataille – (Wageningen University & Research)

*Co-External Supervisor:* Dr. Zhao Hong – (Wageningen University & Research)

*Co-External Supervisor:* Dr. Bart Kruijt – (Wageningen University & Research)

*1st Internal Assessor:* Dr. Christian Fritz – (Radboud University) 

*2nd Internal Assessor:* Dr. Jochem Kali (University of Duisburg-Essen)



## Repository Structure 

The repository consists of *4* different folders which hosts various scripts used for particular stages in the thesis.

- **00_Downloading_Data:** Various different Google Earth Engine scripts used to procure various different remotely sensed data. 
- **01_Pre_Processing:** Scripts used to preprocess the all the procured datasets. 
- **02_ML_Model_Optimization:** Scripts used to train and optimize the Boosted Regression Tree (BRT) model.
- **03_GHG_SMC_Modelling:** Scripts to perform non-linear regression between Net Ecosystem Exchange (NEE) and Planet Soil Moisture Content (SMC).     

## Thesis Abstract 

Peatlands play a critical role in the global carbon cycle, yet field-scale soil moisture and its control over carbon exchange remain difficult to map. In this study, two high-resolution microwave-based soil moisture products were evaluated against in situ probes across ten Dutch peatland sites, and a Boosted Regression Tree (BRT) model was developed incorporating remotely sensed, ground-based, and ancillary predictors.  Soil moisture content (SMC) from Planetary Variables™ outperformed Sentinel-1 in capturing moisture variability, while the optimised BRT explained 67 % of observed SMC (RMSE = 0.09 m³m⁻³). Further, a non-linear respiration model substituting water-table depth with surface moisture was related to nighttime net ecosystem exchange data, accounting for 62 % of variance and revealing a unimodal moisture respiration response. These findings demonstrate that when coupled with machine learning and process-informed modelling, high-resolution soil moisture products offer a robust framework for mapping peatland hydrology and forecasting carbon fluxes.

### 

