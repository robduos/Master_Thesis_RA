## Table of scripts used to create the final merged dataset

| Script Name | Description | Link |
|------------|------------|-------------|
| 01_01_Filter_Merge_EC_Tower_Data  | This script merges all the individual CSV files of the NOBV EC Tower Locations into one dataframe, and exports the merged CSV file | [View Script]() |
| 01_02_Filter_Merge_EC_Tower_Data_GPP  | This script reads and extracts GPP_NT & RECO_NT from all the individual NOBV CSV Files, computes the daily averages of the features, reads the pre-processed complete dataset, merges the two columns to the complete dataset and exports the merged dataset. | [View Script]() |
| 01_03_Compute_Nighttime_NEE | This script loads a pre-processed dataset, converts the units of NEE variables and computes the nighttime, daytime.  | [View Script]() |
| 01_04_Temporal_Aggregation_EC_Tower Data | This script performs temporal aggregation (daily averages) of the merged dataframe.  | [View Script]() |
| 01_05_Compute_Evapotranspiration | This script loads a pre-processed dataset, and computes the Potential Evapotranspiration and Reference Evapotranspiration. | [View Script]() |
| 01_06_Extract_BOFEK_Data | This script calculates key soil hydraulic properties (Wilting Point, Saturation, Porosity) using the BOFEK2020 methodology and source data. It loads site data containing BOFEK2020 unit assignments, maps these units to their dominant soil profiles using the official BOFEK2020 results table, retrieves the layer structure for these profiles, looks up the corresponding Staringreeks 2018 Mualem-Van Genuchten parameters, calculates the hydraulic properties per layer, and finally aggregates or selects these properties based on a user-defined target depth or interval.  | [View Script]() |
| 01_07_Extract_OWASIS_Data | This script extracts all three OWASIS variables from the TIFF files and exports the data as CSV files | [View Script]() |
| 01_08_Extract_Planet_Data | This script extracts the swc & swc-qf variables from all the individual netCDF4 files and exports a merged CSV file.  | [View Script]() |
| 01_09_Extract_BIS_4D_Data | This script extracts all variables avaiable from the BIS-4D datasets for the NOBV locations into one CSV file. | [View Script]() |
| 01_10_Final_Merging | This script merges all the individual datasets to one pre-processed dataset | [View Script]() |
| 01_11_Seasonal_Splitting | This script loads the complete merged dataset, and splits the dataset to two seasonal periods. | [View Script]() |