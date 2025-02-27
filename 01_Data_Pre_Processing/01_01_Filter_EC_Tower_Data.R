# HEADER
# File: 01_Pre_Processing_Read_Filter_EC_Tower_Data.R
# Date: 2025
# Created by: Rob Alamgir  
# Version: 1.0
# R version used: 4.3.2

#----------------------------Import relevant packages-------------------------------------
suppressMessages(suppressWarnings(require(raster))) 
suppressMessages(suppressWarnings(require(sf))) 
suppressMessages(suppressWarnings(require(ggplot2))) 
suppressMessages(suppressWarnings(require(cowplot))) 
suppressMessages(suppressWarnings(require(dplyr))) 
suppressMessages(suppressWarnings(require(tidyr))) 
suppressMessages(suppressWarnings(require(lubridate))) 
suppressMessages(suppressWarnings(require(zoo))) 
suppressMessages(suppressWarnings(require(xts))) 

setwd("C:/Data_MSc_Thesis/EC_Tower_Data") #Set Working Directory

#----------------------------Import all the CSV files--(Updated CSV Files)----------
# List CSV files with the specified pattern
EC_TOWER_CSV_Files <- list.files(path = "C:/Data_MSc_Thesis/EC_Tower_Data/Friesland_EC_Tower_Data", 
                                 full.names = TRUE, pattern = "*.csv") #import EC_Tower data
print(EC_TOWER_CSV_Files)

# Loop through each file, load it, and assign the dataframe name based on the file name
for (file in EC_TOWER_CSV_Files) {
  df_name <- gsub("\\.csv$", "", basename(file)) # Extract the base name without the file extension
  df <- read.csv(file) # Load the csv file
  assign(df_name, df) # Assign the dataframe to the corresponding variable name
}

#----------------------------Explore and Plot Data (ALB_MS)------------------------------
print(colnames(ALB_MS)) # Print the column names of the specific dataframe

ALB_MS_df <- ALB_MS %>% select(datetime,DOY,                                 # General Metadata
                               SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                               STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                               SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                               WTMP_f,                                       # Water Temperature
                               WLEV_f,                                       # Water Level
                               
                               # Meteorological Measurements
                               ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                               PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                               VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                               DTMP_f,                                       # Dew Point Temperature
                               WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                               WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                               RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                               RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                                                                                      
                               NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                               NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                               NEE_H2O,                                      # Net Ecosystem Exchange H20
                               RECO_NT,                                      # (NT) Night Time
                               
                               # Radiation Measurements
                               SWIN_f,                                       # Shortwave Infrared Radiation
                               #SWOT_f,                                      # Shortwave Outgoing Radiation
                               PAR,PAR_f,                                    # Photosynthetically Active Radiation
                               LWIN_f,                                       # Longwave Infrared Radiation Incoming
                               #LWOT_f,                                      # Longwave Outgoing Radiation
                               #RNR_f,                                       # Net Radiation
                               #RPR_f,                                       # Radiation Pressure  
                               NIR,NIR_f,                                    # Near-Infrared radiation
                               ALBE_f)                                       # Albedo
                               #NDVI_f)
                               
ALB_MS_df <- ALB_MS_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("ALB_MS_", .)), everything()) # Add prefix "ALB_MS_" to all column names except the date column
ALB_MS_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", ALB_MS_df$datetime)              # Remove placeholder
ALB_MS_df$datetime <- as.POSIXct(ALB_MS_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
ALB_MS_df$DOY <- gsub("\\[ddd.ddd\\]", "", ALB_MS_df$DOY)                           # Remove placeholder
ALB_MS_df$DOY <- as.numeric(ALB_MS_df$DOY)                                          # Convert to numeric
ALB_MS_df <- ALB_MS_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
ALB_MS_df <- ALB_MS_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
ALB_MS_df <- ALB_MS_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
ALB_MS_df <- ALB_MS_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
ALB_MS_df <- ALB_MS_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(ALB_MS_df)
summary(ALB_MS_df)

#----------------------------Explore and Plot Data (ALB_RF)------------------------------

#print(colnames(ALB_RF)) # Print the column names of the specific dataframe

ALB_RF_df <- ALB_RF %>% select(datetime,DOY,                                 # General Metadata
                               SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                               STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                               SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                               WTMP_f,                                       # Water Temperature
                               WLEV_f,                                       # Water Level
                               
                               # Meteorological Measurements
                               ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                               PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                               VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                               DTMP_f,                                       # Dew Point Temperature
                               WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                               WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                               RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                               RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                               
                               NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                               NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                               NEE_H2O,                                      # Net Ecosystem Exchange H20
                               RECO_NT,                                      # (NT) Night Time
                               
                               # Radiation Measurements
                               SWIN_f,                                       # Shortwave Infrared Radiation
                               SWOT_f,                                       # Shortwave Outgoing Radiation
                               PAR,PAR_f,                                    # Photosynthetically Active Radiation
                               LWIN_f,                                       # Longwave Infrared Radiation Incoming
                               LWOT_f,                                       # Longwave Outgoing Radiation
                               RNR_f,                                        # Net Radiation
                               RPR_f,                                        # Radiation Pressure  
                               NIR,NIR_f,                                    # Near-Infrared radiation
                               ALBE_f,                                       # Albedo
                               NDVI_f)

ALB_RF_df <- ALB_RF_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("ALB_RF_", .)), everything()) # Add prefix "ALB_RF_" to all column names except the date column
ALB_RF_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", ALB_RF_df$datetime)              # Remove placeholder
ALB_RF_df$datetime <- as.POSIXct(ALB_RF_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
ALB_RF_df$DOY <- gsub("\\[ddd.ddd\\]", "", ALB_RF_df$DOY)                           # Remove placeholder
ALB_RF_df$DOY <- as.numeric(ALB_RF_df$DOY)                                          # Convert to numeric
ALB_RF_df <- ALB_RF_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
ALB_RF_df <- ALB_RF_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
ALB_RF_df <- ALB_RF_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
ALB_RF_df <- ALB_RF_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
ALB_RF_df <- ALB_RF_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(ALB_RF_df)
summary(ALB_RF_df)

#----------------------------Explore and Plot Data (AMM)------------------------------
#print(colnames(AMM)) # Print the column names of the specific dataframe

AMM_df <- AMM %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f,                                       # Albedo
                         NDVI_f)

AMM_df <- AMM_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("AMM_", .)), everything()) # Add prefix "AMM_" to all column names except the date column
AMM_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", AMM_df$datetime)              # Remove placeholder
AMM_df$datetime <- as.POSIXct(AMM_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
AMM_df$DOY <- gsub("\\[ddd.ddd\\]", "", AMM_df$DOY)                           # Remove placeholder
AMM_df$DOY <- as.numeric(AMM_df$DOY)                                          # Convert to numeric
AMM_df <- AMM_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
AMM_df <- AMM_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
AMM_df <- AMM_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
AMM_df <- AMM_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
AMM_df <- AMM_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(AMM_df)
summary(AMM_df)

#----------------------------Explore and Plot Data (AMR)------------------------------
#print(colnames(AMR)) # Print the column names of the specific dataframe

AMR_df <- AMR %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f)                                       # Albedo
#NDVI_f)

AMR_df <- AMR_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("AMR_", .)), everything()) # Add prefix "AMR_" to all column names except the date column
AMR_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", AMR_df$datetime)              # Remove placeholder
AMR_df$datetime <- as.POSIXct(AMR_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
AMR_df$DOY <- gsub("\\[ddd.ddd\\]", "", AMR_df$DOY)                           # Remove placeholder
AMR_df$DOY <- as.numeric(AMR_df$DOY)                                          # Convert to numeric
AMR_df <- AMR_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
AMR_df <- AMR_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
AMR_df <- AMR_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
AMR_df <- AMR_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
AMR_df <- AMR_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(AMR_df)
summary(AMR_df)


#----------------------------Explore and Plot Data (BUO)------------------------------
#print(colnames(BUO)) # Print the column names of the specific dataframe

BUO_df <- BUO %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f,                                       # Albedo
                         NDVI_f)

BUO_df <- BUO_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("BUO_", .)), everything()) # Add prefix "BUO_" to all column names except the date column
BUO_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", BUO_df$datetime)              # Remove placeholder
BUO_df$datetime <- as.POSIXct(BUO_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
BUO_df$DOY <- gsub("\\[ddd.ddd\\]", "", BUO_df$DOY)                           # Remove placeholder
BUO_df$DOY <- as.numeric(BUO_df$DOY)                                          # Convert to numeric
BUO_df <- BUO_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
BUO_df <- BUO_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
BUO_df <- BUO_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
BUO_df <- BUO_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
BUO_df <- BUO_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(BUO_df)
summary(BUO_df)

#----------------------------Explore and Plot Data (BUW)------------------------------
#print(colnames(BUW)) # Print the column names of the specific dataframe

BUW_df <- BUO %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f,                                       # Albedo
                         NDVI_f)

BUW_df <- BUW_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("BUW_", .)), everything()) # Add prefix "BUW_" to all column names except the date column
BUW_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", BUW_df$datetime)              # Remove placeholder
BUW_df$datetime <- as.POSIXct(BUW_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
BUW_df$DOY <- gsub("\\[ddd.ddd\\]", "", BUW_df$DOY)                           # Remove placeholder
BUW_df$DOY <- as.numeric(BUW_df$DOY)                                          # Convert to numeric
BUW_df <- BUW_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
BUW_df <- BUW_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
BUW_df <- BUW_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
BUW_df <- BUW_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
BUW_df <- BUW_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(BUW_df)
summary(BUW_df)

#----------------------------Explore and Plot Data (HOC)------------------------------
#print(colnames(HOC)) # Print the column names of the specific dataframe

HOC_df <- HOC %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f,                                       # Albedo
                         NDVI_f)

HOC_df <- HOC_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("HOC_", .)), everything()) # Add prefix "HOC_" to all column names except the date column
HOC_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", HOC_df$datetime)              # Remove placeholder
HOC_df$datetime <- as.POSIXct(HOC_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
HOC_df$DOY <- gsub("\\[ddd.ddd\\]", "", HOC_df$DOY)                           # Remove placeholder
HOC_df$DOY <- as.numeric(HOC_df$DOY)                                          # Convert to numeric
HOC_df <- HOC_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
HOC_df <- HOC_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
HOC_df <- HOC_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
HOC_df <- HOC_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
HOC_df <- HOC_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(HOC_df)
summary(HOC_df)



#----------------------------Explore and Plot Data (HOH)------------------------------
#print(colnames(HOH)) # Print the column names of the specific dataframe

HOH_df <- HOH %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f,                                       # Albedo
                         NDVI_f)

HOH_df <- HOH_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("HOH_", .)), everything()) # Add prefix "HOH_" to all column names except the date column
HOH_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", HOH_df$datetime)              # Remove placeholder
HOH_df$datetime <- as.POSIXct(HOH_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
HOH_df$DOY <- gsub("\\[ddd.ddd\\]", "", HOH_df$DOY)                           # Remove placeholder
HOH_df$DOY <- as.numeric(HOH_df$DOY)                                          # Convert to numeric
HOH_df <- HOH_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
HOH_df <- HOH_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
HOH_df <- HOH_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
HOH_df <- HOH_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
HOH_df <- HOH_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(HOC_df)
summary(HOC_df)


#----------------------------Explore and Plot Data (LDC)------------------------------
print(colnames(LDC)) # Print the column names of the specific dataframe

LDC_df <- LDC %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f,                                       # Albedo
                         NDVI_f)

LDC_df <- LDC_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("LDC_", .)), everything()) # Add prefix "LDC_" to all column names except the date column
LDC_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", LDC_df$datetime)              # Remove placeholder
LDC_df$datetime <- as.POSIXct(LDC_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
LDC_df$DOY <- gsub("\\[ddd.ddd\\]", "", LDC_df$DOY)                           # Remove placeholder
LDC_df$DOY <- as.numeric(LDC_df$DOY)                                          # Convert to numeric
LDC_df <- LDC_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
LDC_df <- LDC_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
LDC_df <- LDC_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
LDC_df <- LDC_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
LDC_df <- LDC_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'

str(LDC_df)
summary(LDC_df)


#----------------------------Explore and Plot Data (LDH)------------------------------
#print(colnames(LDH)) # Print the column names of the specific dataframe

LDH_df <- LDH %>% select(datetime,DOY,                                 # General Metadata
                         SWCT_1_005, SWCT_3_005, SWCT_1_015,           # Soil Moisture 5cm & 15cm [SENTEK]
                         STMP_1_005,STMP_3_005,STMP_1_015,STMP_3_015,  # Soil Temperature 5cm & 15cm [SENTEK]
                         SHF_1_f, SHF_2_f,                             # Soil Heat Flux
                         WTMP_f,                                       # Water Temperature
                         WLEV_f,                                       # Water Level
                         
                         # Meteorological Measurements
                         ATMP, ATMP_f, TA_KNMI_270,                    # Air Temperature [Gill maximet GMX500], [Gap-Filled] & [KNMI] 
                         PAIR, PAIR_f, PA_KNMI_270,                    # Air Pressure [Gill maximet GMX500] , [Gap-Filled] & [KNMI]
                         VPD_EP, VPD_f,                                # Vapor Pressure Deficit [] & [Gap-Filled] 
                         DTMP_f,                                       # Dew Point Temperature
                         WIND_f,WD_KNMI_270,                           # Wind Direction [Gill maximet GMX500] & [KMNI]
                         WINS,WINS_f,SWIN_KNMI_270,                    # Wind Speed     [Gill maximet GMX500] & [KMNI]
                         RAIN,RAIN_f,RAIN_KNMI_270,                    # Rainfall  [ARG314], [Gap-Filled] & [KMNI]
                         RHUM,RHUM_EP,RHUM_f,RH_KNMI_270,              # Relative Humidity [], [], [Gap-Filled] & [KMNI]
                         
                         NEE_CO2,NEE_CO2_MDS,                          # Net Ecosystem Exchange CO2
                         NEE_CH4,NEE_CH4_MDS,                          # Net Ecosystem Exchange CH4
                         NEE_H2O,                                      # Net Ecosystem Exchange H20
                         RECO_NT,                                      # (NT) Night Time
                         
                         # Radiation Measurements
                         SWIN_f,                                       # Shortwave Infrared Radiation
                         SWOT_f,                                      # Shortwave Outgoing Radiation
                         PAR,PAR_f,                                    # Photosynthetically Active Radiation
                         LWIN_f,                                       # Longwave Infrared Radiation Incoming
                         LWOT_f,                                      # Longwave Outgoing Radiation
                         RNR_f,                                       # Net Radiation
                         RPR_f,                                       # Radiation Pressure  
                         NIR,NIR_f,                                    # Near-Infrared radiation
                         ALBE_f,                                       # Albedo
                         NDVI_f)

LDH_df <- LDH_df %>%
  rename_with(~ ifelse(. %in% c("datetime", "DOY"), ., paste0("LDH_", .)), everything()) # Add prefix "LDH_" to all column names except the date column
LDH_df$datetime <- gsub("yyyy-mm-dd HH:MM", "", LDH_df$datetime)              # Remove placeholder
LDH_df$datetime <- as.POSIXct(LDH_df$datetime, format = "%Y-%m-%d %H:%M:%S")  # Convert to POSIXct
LDH_df$DOY <- gsub("\\[ddd.ddd\\]", "", LDH_df$DOY)                           # Remove placeholder
LDH_df$DOY <- as.numeric(LDH_df$DOY)                                          # Convert to numeric
LDH_df <- LDH_df %>% mutate(time = format(datetime, "%H:%M:%S"))          # Create a new 'time' column by extracting the time from the 'datetime' column
LDH_df <- LDH_df %>% mutate(date = as.Date(datetime))                     # Create a new 'date' column by extracting the date from 'datetime' and converting it to Date format
LDH_df <- LDH_df %>% relocate(date, .after = datetime)                    # Reorder columns to place 'time' next to 'datetime'
LDH_df <- LDH_df %>% relocate(time, .after = date)                        # Reorder columns to place 'time' next to 'datetime'
LDH_df <- LDH_df %>% mutate(across(-c(datetime, date, time), as.numeric)) # Convert all columns to numeric format except for 'datetime' and 'date'



#----------------------------Save the Dataframes as CSV files--------------------

str(ALB_MS_df)
str(ALB_RF_df)
str(AMM_df)
str(AMR_df)
str(BUO_df)
str(BUW_df)
str(HOC_df)
str(HOH_df)
str(LDC_df)
str(LDH_df)

# Define the folder path where you want to save the CSV files
folder_path <- "C:/Data_MSc_Thesis/EC_Tower_Data/Friesland_EC_Tower_Data_Selected_Data"

# Ensure the folder exists or create it if not
if(!dir.exists(folder_path)) {
  dir.create(folder_path)
}

# List of dataframes and their corresponding names
df_list <- list(ALB_MS_df, ALB_RF_df, AMM_df, AMR_df, BUO_df, BUW_df, HOC_df, HOH_df, LDC_df, LDH_df)
df_names <- c("ALB_MS_df", "ALB_RF_df", "AMM_df", "AMR_df", "BUO_df", "BUW_df", "HOC_df", "HOH_df", "LDC_df", "LDH_df")

# Loop through each dataframe and write it to a CSV file
for(i in seq_along(df_list)) {
  write.csv(df_list[[i]], file = paste0(folder_path, "/", df_names[i], ".csv"), row.names = FALSE)
}

# Output the path to check
folder_path


#----------------------------
