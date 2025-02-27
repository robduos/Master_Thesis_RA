# HEADER
# File: 01_05_Merging_LST_LAI_S2_Data.R
# Date: 2025
# Created by: Rob Alamgir  
# Version: 1.0

# R version used: 4.3.2

#-----------------------------import relevant packages-------------------------------------
suppressMessages(suppressWarnings(require(raster))) 
suppressMessages(suppressWarnings(require(sf))) 
suppressMessages(suppressWarnings(require(ggplot2))) 
suppressMessages(suppressWarnings(require(ggspatial))) 
suppressMessages(suppressWarnings(require(cowplot))) 
suppressMessages(suppressWarnings(require(tmap))) 
suppressMessages(suppressWarnings(require(tmaptools))) 
suppressMessages(suppressWarnings(require(viridis))) 
suppressMessages(suppressWarnings(require(stringr))) 
suppressMessages(suppressWarnings(require(dplyr))) 
suppressMessages(suppressWarnings(require(stats))) 
suppressMessages(suppressWarnings(require(tidyr))) 
suppressMessages(suppressWarnings(require(stars)))
suppressMessages(suppressWarnings(require(RColorBrewer)))
suppressMessages(suppressWarnings(require(lubridate)))
suppressMessages(suppressWarnings(require(zoo)))
suppressMessages(suppressWarnings(require(xts)))
suppressMessages(suppressWarnings(require(ncdf4)))
suppressMessages(suppressWarnings(require(terra)))
suppressMessages(suppressWarnings(require(reshape2)))
suppressMessages(suppressWarnings(require(tidyverse)))
suppressMessages(suppressWarnings(require(scales)))
suppressMessages(suppressWarnings(require(purrr)))
suppressMessages(suppressWarnings(require(readr)))

setwd("C:/Data_MSc_Thesis/") # Set Working Directory

#-----------------------------Load & Inspect all the CSV files-------------------------------------
L8_9_LST_CSV_Files <- list.files(path = "C:/Data_MSc_Thesis/L8_L9_LST/", full.names = TRUE, pattern = "*.csv") 
print(L8_9_LST_CSV_Files)

S2_Indices_CSV_Files <- list.files(path = "C:/Data_MSc_Thesis/S2_Indices/", full.names = TRUE, pattern = "*.csv") 
print(S2_Indices_CSV_Files)

MODIS_CSV_Files <- list.files(path = "C:/Data_MSc_Thesis/MODIS_LAI/", full.names = TRUE, pattern = "*.csv") 
print(MODIS_CSV_Files)

#-----------------------------Import all the CSV files an merge them------------
# Function to read a file and add a base name column
read_and_add_name <- function(file) {
  base_name <- tools::file_path_sans_ext(basename(file))
  read_csv(file) %>%
    mutate(Source = base_name)}

# Apply function to L8_9_LST Data
L8_9_LST_merged <- map_dfr(L8_9_LST_CSV_Files, read_and_add_name) 

L8_9_LST_merged <- L8_9_LST_merged %>%
  rename(L8_9_LST = 'Mean_Surface_Temperature') %>%
  mutate(Date = as.Date(Date, format = "%b %d, %Y")) %>%
  select(-`system:index`, -`.geo`)

L8_9_LST_merged_df <- as.data.frame(L8_9_LST_merged) 

# Apply function to S2_Indices_CSV_Files
S2_Indices_merged <- map_dfr(S2_Indices_CSV_Files, read_and_add_name) 

S2_Indices_merged <- S2_Indices_merged %>%
  rename(S2_NDVI = 'NDVI') %>%
  rename(S2_EVI = 'EVI') %>%
  rename(S2_NDMI = 'NDMI') %>%
  select(-`MNDWI`, -`STR`)%>%
  na.omit()

S2_Indices_merged_df <- as.data.frame(S2_Indices_merged) 

# Apply function to MODIS_Terra_LAI
MODIS_LAI_merged <- map_dfr(MODIS_CSV_Files, read_and_add_name) 

MODIS_LAI_merged <- MODIS_LAI_merged %>%
  rename(MODIS_LAI = 'Mean_LAI') %>%
  select(-`system:index`, -`.geo`)

MODIS_LAI_merged_df <- as.data.frame(MODIS_LAI_merged) 

#write.csv(MODIS_LAI_merged_df, "C:/Data_MSc_Thesis/MODIS_LAI/MODIS_LAI_merged.csv")



