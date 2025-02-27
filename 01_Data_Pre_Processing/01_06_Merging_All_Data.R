# HEADER
# File: 01_06_Merging_All_Data.R
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

#---------------------------- Load & Inspect all the CSV files--------------------------
# List CSV files with the specified pattern
Planet_SWC_CSV_files <- list.files(path = "C:/Data_MSc_Thesis/Planet/NOBV_Planet_Inc_Data/", full.names = TRUE, pattern = "*Planet.csv") #import Planet data
print(Planet_SWC_CSV_files)

S1_SAR_VSM_CSV_files <- list.files(path = "S1_SAR_VSM/Final_S1_SAR_VSM_Data/", full.names = TRUE, pattern = "*VSM.csv") #import S1_SAR_VSM data
print(S1_SAR_VSM_CSV_files)

S1_Backscatter_CSV_files <- list.files(path = "S1_SAR_Backscatter/", full.names = TRUE, pattern = "*Scat.csv") #import S1_Backscatter data
print(S1_Backscatter_CSV_files)

EC_Tower_Data_file <- read.csv("C:/Data_MSc_Thesis/EC_Tower_Data/EC_Tower_Data_Daily_Mean_updated.csv") #Extract EC Tower Data 
print(EC_Tower_Data_file)

OWASIS_CSV_files <- list.files(path = "C:/Data_MSc_Thesis/OWASIS/EC_Tower_OWASIS_Data/", full.names = TRUE, pattern = "*OWASIS.csv") #Extract OWASIS Data 
print(OWASIS_CSV_files)

S2_Indices_CSV_Files <- list.files(path = "C:/Data_MSc_Thesis/S2_Indices/", full.names = TRUE, pattern = "*.csv") 
print(S2_Indices_CSV_Files)

L8_L9_LST <- read.csv("C:/Data_MSc_Thesis/L8_L9_LST/L8_9_LST_merged.csv")
str(L8_L9_LST)

MODIS_LAI <- read.csv("C:/Data_MSc_Thesis/MODIS_LAI/MODIS_LAI_merged.csv")
str(MODIS_LAI)

#-----------------------------Import all the CSV files an merge them--------------------------------------------
# Function to read a file and add a base name column
read_and_add_name <- function(file) {
  base_name <- tools::file_path_sans_ext(basename(file))
  read_csv(file) %>%
    mutate(Source = base_name)}

# Apply function to S1_SAR_VSM Data
S1_SAR_VSM_merged <- map_dfr(S1_SAR_VSM_CSV_files, read_and_add_name) # Apply the function to each file and combine results
#str(S1_SAR_VSM_merged)
S1_SAR_VSM_merged <- S1_SAR_VSM_merged %>%
  rename(Date = 'system:time_start') %>% # Rename 'system:time_start' column
  mutate(Date = as.Date(Date, format = "%b %d, %Y")) %>%  # Convert to Date format
  filter(Date >= as.Date("2020-01-01")) %>% # Filer date rows before 01.01.2020
  select(-pixel_count)
S1_SAR_VSM_merged_df <- as.data.frame(S1_SAR_VSM_merged) # Convert to a dataframe
str(S1_SAR_VSM_merged_df) # View the structure to confirm changes
unique(S1_SAR_VSM_merged_df$Source)
summary(S1_SAR_VSM_merged_df)

# Apply function to S1_Backscatter Data
S1_Backscatter_merged <- map_dfr(S1_Backscatter_CSV_files, read_and_add_name) # Apply the function to each file and combine results
#str(S1_Backscatter_merged)
#unique(S1_Backscatter_merged$Source)

S1_Backscatter_merged <- S1_Backscatter_merged %>%
  mutate(Date = as.Date(Date, format = "%b %d, %Y")) %>%  # Convert to Date format
  select(-count)%>%
  filter(Source != "S1_SAR_WRW_OW_Back_Scat")
S1_Backscatter_merged_df <- as.data.frame(S1_Backscatter_merged) # Convert to a dataframe
str(S1_Backscatter_merged_df) # View the structure to confirm changes
#unique(S1_Backscatter_merged_df$Source)

# Apply function to Planet_SWC Data
Planet_SWC_merged <- map_dfr(Planet_SWC_CSV_files, read_and_add_name) # Apply the function to each file and combine results
#str(Planet_SWC_merged)
#unique(Planet_SWC_merged$Source)

Planet_SWC_merged <- Planet_SWC_merged %>%
  rename(Date = 'timestamp') %>% # Rename 'timestamp' column
  mutate(Date = as.Date(Date, format = "%b %d, %Y")) %>% # Convert to Date format
  filter(Source != "WRW_OW_SWC_Planet") 

Planet_SWC_merged_df <- as.data.frame(Planet_SWC_merged) # Convert to a dataframe
str(Planet_SWC_merged_df) # View the structure to confirm changes
unique(Planet_SWC_merged_df$Source)
summary(Planet_SWC_merged_df)

# Apply function to OWASIS Data
OWASIS_merged <- map_dfr(OWASIS_CSV_files, read_and_add_name) # Apply the function to each file and combine results
OWASIS_merged_df <- as.data.frame(OWASIS_merged) # Convert to a dataframe
OWASIS_merged_df <- as.data.frame(OWASIS_merged) %>%
  select(-V1,-x,-y) %>%
  rename(Date = 'date') %>%
  filter(!is.na(Date)) 

str(OWASIS_merged_df) # View the structure to confirm changes
unique(OWASIS_merged_df$Source)
summary(OWASIS_merged_df)

# Prep EC Tower Data 
EC_Tower_Data_file$date <- as.Date(EC_Tower_Data_file$date, format = "%Y-%m-%d")
EC_Tower_Data_file[, -which(names(EC_Tower_Data_file) == "date")] <- 
  lapply(EC_Tower_Data_file[, -which(names(EC_Tower_Data_file) == "date")], as.numeric) # Convert all columns except the date column to numeric
EC_Tower_Data_file <- EC_Tower_Data_file[order(EC_Tower_Data_file$date), ] # Sort the dataframe by the date column in ascending order

str(EC_Tower_Data_file)
summary(EC_Tower_Data_file)

# Apply function to S2_Indices_CSV_Files
S2_Indices_merged <- map_dfr(S2_Indices_CSV_Files, read_and_add_name) 

S2_Indices_merged <- S2_Indices_merged %>%
  rename(S2_NDVI = 'NDVI') %>%
  rename(S2_EVI = 'EVI') %>%
  rename(S2_NDMI = 'NDMI') %>%
  select(-`MNDWI`, -`STR`)

S2_Indices_merged_df <- as.data.frame(S2_Indices_merged)
S2_Indices_merged_df_clean <- na.omit(S2_Indices_merged_df)
attr(S2_Indices_merged_df_clean, "na.action") <- NULL
str(S2_Indices_merged_df_clean) 
summary(S2_Indices_merged_df_clean)
unique(S2_Indices_merged_df_clean$Source)

# Prep Landsat 8 & 9 data 
L8_L9_LST$Date <- as.Date(L8_L9_LST$Date, format = "%d/%m/%Y")
str(L8_L9_LST)   
unique(L8_L9_LST$Source)

# Prep MODIS LAI
MODIS_LAI <- MODIS_LAI %>%
  select(-X)
MODIS_LAI$Date <- as.Date(MODIS_LAI$Date, format = "%Y-%m-%d")
str(MODIS_LAI)   
unique(MODIS_LAI$Source)

#-----------------------------Merge the imported dataframes-----
# Updated function to clean the 'Source' column
clean_source <- function(df, patterns) {
  for (pattern in patterns) {
    df$Source <- gsub(pattern, "", df$Source)
  }
  return(df)
}

patterns_to_remove <- c("_VSM", "_Back_Scat", "S1_SAR_", "_SWC_Planet", "_OWASIS", "S2_Indices_","L8_9_LST_", "MODIS_LAI_") # Define the patterns to remove

# Apply the function to clean the source columns of dataframes
S1_SAR_VSM_merged_df <- clean_source(S1_SAR_VSM_merged_df, patterns_to_remove)
S1_Backscatter_merged_df <- clean_source(S1_Backscatter_merged_df, patterns_to_remove)
Planet_SWC_merged_df <- clean_source(Planet_SWC_merged_df, patterns_to_remove)
OWASIS_merged_df <- clean_source(OWASIS_merged_df, patterns_to_remove)
S2_Indices_merged_df_clean <- clean_source(S2_Indices_merged_df_clean,patterns_to_remove)
L8_L9_LST <- clean_source(L8_L9_LST,patterns_to_remove)
MODIS_LAI <- clean_source(MODIS_LAI,patterns_to_remove)

# Rename the rows of two locations throughout the data frame
Planet_SWC_merged_df <- Planet_SWC_merged_df %>%
  mutate(Source = case_when(Source == "AMM_RF" ~ "AMM",
                            Source == "AMR_RF" ~ "AMR",
                            TRUE ~ Source))  # Keep other values unchanged

# Merging S1 VSM dataframe with S1 Backscatter dataframe 
S1_merged_df <- merge(S1_SAR_VSM_merged_df, S1_Backscatter_merged_df,  
                   by = c("Date", "Source"), 
                   all = TRUE)

# View the structure of the merged dataframe
#str(S1_merged_df)
summary(S1_merged_df)
unique(S1_merged_df$Source)

# Merging the previous merged dataframe (S1 VSM & S1 Backscatter) with Planet SWC Data 
S1_planet_merged_df <- merge(S1_merged_df, Planet_SWC_merged_df,
                            by = c("Date", "Source"),
                            all = TRUE)

# Rename the columns of the merged dataframe
S1_planet_merged_df <- S1_planet_merged_df %>%
  rename(S1_Backscatter = 'mean') %>% 
  rename(S1_VSM = 'VSM') 
  
# View the structure of the merged dataframe
str(S1_planet_merged_df)
summary(S1_planet_merged_df)
unique(S1_planet_merged_df$Source)


# Merging the previous merged dataframe with OWASIS Data 
S1_planet_merged_OWASIS_df <- merge(S1_planet_merged_df, OWASIS_merged_df,
                                    by = c("Date", "Source"),
                                    all = TRUE)

str(S1_planet_merged_OWASIS_df)
summary(S1_planet_merged_OWASIS_df)
unique(S1_planet_merged_OWASIS_df$Source)


S2_S1_Planet_OWASIS <- merge(S1_planet_merged_OWASIS_df, S2_Indices_merged_df_clean,
                             by = c("Date", "Source"),
                             all = TRUE)

str(S2_S1_Planet_OWASIS)
summary(S2_S1_Planet_OWASIS)
unique(S2_S1_Planet_OWASIS$Source)

S2_S1_Planet_OWASIS_L8_L9 <- merge(S2_S1_Planet_OWASIS, L8_L9_LST,
                             by = c("Date", "Source"),
                             all = TRUE)

str(S2_S1_Planet_OWASIS_L8_L9)
summary(S2_S1_Planet_OWASIS_L8_L9)
unique(S2_S1_Planet_OWASIS_L8_L9$Source)


S2_S1_Planet_OWASIS_L8_L9_MODIS <- merge(S2_S1_Planet_OWASIS_L8_L9, MODIS_LAI,
                                   by = c("Date", "Source"),
                                   all = TRUE)

str(S2_S1_Planet_OWASIS_L8_L9_MODIS)
summary(S2_S1_Planet_OWASIS_L8_L9_MODIS)
unique(S2_S1_Planet_OWASIS_L8_L9_MODIS$Source)


#----------------------Merging EC Tower data with the previous merged dataframe----
EC_Tower_selected_ALB_MS <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = ALB_MS_SWCT_1_005,
         SWCT_3_005 = ALB_MS_SWCT_3_005,
         SWCT_1_015 = ALB_MS_SWCT_1_015,        
         STMP_1_005 = ALB_MS_STMP_1_005,
         STMP_3_005 = ALB_MS_STMP_3_005,
         STMP_1_015 = ALB_MS_STMP_1_015,
         STMP_3_015 = ALB_MS_STMP_3_015,
         SHF_1_f = ALB_MS_SHF_1_f,
         SHF_2_f = ALB_MS_SHF_2_f,                                                         
         WTMP_f = ALB_MS_WTMP_f,                                      
         WLEV_f = ALB_MS_WLEV_f,                                      
         ATMP = ALB_MS_ATMP,
         ATMP_f = ALB_MS_ATMP_f,
         TA_KNMI_270 = ALB_MS_TA_KNMI_270,                 
         PAIR = ALB_MS_PAIR,
         PAIR_f = ALB_MS_PAIR_f,
         PA_KNMI_270 = ALB_MS_PA_KNMI_270,                 
         VPD_EP = ALB_MS_VPD_EP,
         VPD_f = ALB_MS_VPD_f,                              
         DTMP_f  = ALB_MS_DTMP_f,                                    
         WIND_f  = ALB_MS_WIND_f,
         WD_KNMI_270 = ALB_MS_WD_KNMI_270,                          
         WINS = ALB_MS_WINS,
         WINS_f = ALB_MS_WINS_f,
         SWIN_KNMI_270 = ALB_MS_SWIN_KNMI_270,                  
         RAIN = ALB_MS_RAIN,
         RAIN_f = ALB_MS_RAIN_f,
         RAIN_KNMI_270 = ALB_MS_RAIN_KNMI_270,                  
         RHUM = ALB_MS_RHUM,
         RHUM_EP = ALB_MS_RHUM_EP,
         RHUM_f = ALB_MS_RHUM_f,
         RH_KNMI_270 = ALB_MS_RH_KNMI_270,            
         NEE_CO2 = ALB_MS_NEE_CO2,
         NEE_CO2_MDS = ALB_MS_NEE_CO2_MDS,                         
         NEE_CH4 = ALB_MS_NEE_CH4,
         NEE_CH4_MDS = ALB_MS_NEE_CH4_MDS,                         
         NEE_H2O = ALB_MS_NEE_CH4_MDS,                                     
         RECO_NT = ALB_MS_RECO_NT,                                     
         SWIN_f = ALB_MS_SWIN_f,                                      
         PAR = ALB_MS_PAR,
         PAR_f = ALB_MS_PAR_f,                                   
         LWIN_f = ALB_MS_LWIN_f,
         NIR = ALB_MS_NIR,
         NIR_f = ALB_MS_NIR_f,                                  
         ALBE_f = ALB_MS_ALBE_f)%>%
  mutate(Source = "ALB_MS")  # Add 'Source' column for the ALB_MS location

EC_Tower_selected_ALB_MS$date <- as.Date(EC_Tower_selected_ALB_MS$date, format = "%Y-%m-%d")
#str(EC_Tower_selected_ALB_MS)

# Merge by both 'Date' and 'Source' columns
EC_Tower_Merge <- merge(S2_S1_Planet_OWASIS_L8_L9_MODIS,
                        EC_Tower_selected_ALB_MS,
                        by.x = c("Date", "Source"),
                        by.y = c("date", "Source"),
                        all.x = TRUE)
str(EC_Tower_Merge) # Check the structure of the merged dataframe

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'ALB_RF' location
EC_Tower_selected_ALB_RF <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = ALB_RF_SWCT_1_005,
         SWCT_3_005 = ALB_RF_SWCT_3_005,
         SWCT_1_015 = ALB_RF_SWCT_1_015,        
         STMP_1_005 = ALB_RF_STMP_1_005,
         STMP_3_005 = ALB_RF_STMP_3_005,
         STMP_1_015 = ALB_RF_STMP_1_015,
         STMP_3_015 = ALB_RF_STMP_3_015,
         SHF_1_f = ALB_RF_SHF_1_f,
         SHF_2_f = ALB_RF_SHF_2_f,                                                         
         WTMP_f = ALB_RF_WTMP_f,                                      
         WLEV_f = ALB_RF_WLEV_f,                                      
         ATMP = ALB_RF_ATMP,
         ATMP_f = ALB_RF_ATMP_f,
         TA_KNMI_270 = ALB_RF_TA_KNMI_270,                 
         PAIR = ALB_RF_PAIR,
         PAIR_f = ALB_RF_PAIR_f,
         PA_KNMI_270 = ALB_RF_PA_KNMI_270,                 
         VPD_EP = ALB_RF_VPD_EP,
         VPD_f = ALB_RF_VPD_f,                              
         DTMP_f  = ALB_RF_DTMP_f,                                    
         WIND_f  = ALB_RF_WIND_f,
         WD_KNMI_270 = ALB_RF_WD_KNMI_270,                          
         WINS = ALB_RF_WINS,
         WINS_f = ALB_RF_WINS_f,
         SWIN_KNMI_270 = ALB_RF_SWIN_KNMI_270,                  
         RAIN = ALB_RF_RAIN,
         RAIN_f = ALB_RF_RAIN_f,
         RAIN_KNMI_270 = ALB_RF_RAIN_KNMI_270,                  
         RHUM = ALB_RF_RHUM,
         RHUM_EP = ALB_RF_RHUM_EP,
         RHUM_f = ALB_RF_RHUM_f,
         RH_KNMI_270 = ALB_RF_RH_KNMI_270,            
         NEE_CO2 = ALB_RF_NEE_CO2,
         NEE_CO2_MDS = ALB_RF_NEE_CO2_MDS,                         
         NEE_CH4 = ALB_RF_NEE_CH4,
         NEE_CH4_MDS = ALB_RF_NEE_CH4_MDS,                         
         NEE_H2O = ALB_RF_NEE_CH4_MDS,                                     
         RECO_NT = ALB_RF_RECO_NT,                                     
         SWIN_f = ALB_RF_SWIN_f,                                      
         SWOT_f = ALB_RF_SWOT_f,                                    
         PAR = ALB_RF_PAR,
         PAR_f = ALB_RF_PAR_f,                                   
         LWIN_f = ALB_RF_LWIN_f,                                      
         LWOT_f = ALB_RF_LWOT_f,                                    
         RNR_f = ALB_RF_RNR_f,                                    
         RPR_f = ALB_RF_RPR_f,                                       
         NIR = ALB_RF_NIR,
         NIR_f = ALB_RF_NIR_f,                                  
         ALBE_f = ALB_RF_ALBE_f,                                      
         NDVI_f = ALB_RF_NDVI_f)%>%
  mutate(Source = "ALB_RF")  # Add 'Source' column for the ALB_RF location

EC_Tower_selected_ALB_RF$date <- as.Date(EC_Tower_selected_ALB_RF$date, format = "%Y-%m-%d")
EC_Tower_selected_ALB_RF <- EC_Tower_selected_ALB_RF %>% rename(Date = date) # Make sure the column names are consistent before merging
#str(EC_Tower_selected_ALB_RF)
#summary(EC_Tower_selected_ALB_RF)

EC_Tower_Merged_Final <- EC_Tower_Merge %>%
  left_join(EC_Tower_selected_ALB_RF, by = c("Date", "Source")) # Perform the left join

# Use coalesce to update SWCT and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 , SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f , WTMP_f ,WLEV_f , ATMP, ATMP_f ,TA_KNMI_270, PAIR ,PAIR_f ,PA_KNMI_270,  
         VPD_EP,  VPD_f ,  DTMP_f ,  WIND_f , WD_KNMI_270, WINS ,WINS_f ,SWIN_KNMI_270 , RAIN,RAIN_f ,RAIN_KNMI_270 ,  
         RHUM, RHUM_EP ,RHUM_f ,RH_KNMI_270,  NEE_CO2 ,NEE_CO2_MDS,  NEE_CH4 ,NEE_CH4_MDS , NEE_H2O , RECO_NT , SWIN_f  ,SWOT_f  ,  
         PAR ,PAR_f  , LWIN_f  ,  LWOT_f  ,  RNR_f , RPR_f , NIR_f  , ALBE_f ,  NDVI_f)

str(EC_Tower_Merged_Final)
#summary(EC_Tower_Merged_Final)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'AMM' location
EC_Tower_selected_AMM <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = AMM_SWCT_1_005,
         SWCT_3_005 = AMM_SWCT_3_005,
         SWCT_1_015 = AMM_SWCT_1_015,        
         STMP_1_005 = AMM_STMP_1_005,
         STMP_3_005 = AMM_STMP_3_005,
         STMP_1_015 = AMM_STMP_1_015,
         STMP_3_015 = AMM_STMP_3_015,
         SHF_1_f = AMM_SHF_1_f,
         SHF_2_f = AMM_SHF_2_f,                                                         
         WTMP_f = AMM_WTMP_f,                                      
         WLEV_f = AMM_WLEV_f,                                      
         ATMP = AMM_ATMP,
         ATMP_f = AMM_ATMP_f,
         TA_KNMI_270 = AMM_TA_KNMI_270,                 
         PAIR = AMM_PAIR,
         PAIR_f = AMM_PAIR_f,
         PA_KNMI_270 = AMM_PA_KNMI_270,                 
         VPD_EP = AMM_VPD_EP,
         VPD_f = AMM_VPD_f,                              
         DTMP_f  = AMM_DTMP_f,                                    
         WIND_f  = AMM_WIND_f,
         WD_KNMI_270 = AMM_WD_KNMI_270,                          
         WINS = AMM_WINS,
         WINS_f = AMM_WINS_f,
         SWIN_KNMI_270 = AMM_SWIN_KNMI_270,                  
         RAIN = AMM_RAIN,
         RAIN_f = AMM_RAIN_f,
         RAIN_KNMI_270 = AMM_RAIN_KNMI_270,                  
         RHUM = AMM_RHUM,
         RHUM_EP = AMM_RHUM_EP,
         RHUM_f = AMM_RHUM_f,
         RH_KNMI_270 = AMM_RH_KNMI_270,            
         NEE_CO2 = AMM_NEE_CO2,
         NEE_CO2_MDS = AMM_NEE_CO2_MDS,                         
         NEE_CH4 = AMM_NEE_CH4,
         NEE_CH4_MDS = AMM_NEE_CH4_MDS,                         
         NEE_H2O = AMM_NEE_CH4_MDS,                                     
         RECO_NT = AMM_RECO_NT,                                     
         SWIN_f = AMM_SWIN_f,                                      
         PAR = AMM_PAR,
         PAR_f = AMM_PAR_f,                                   
         LWIN_f = AMM_LWIN_f,
         NIR = AMM_NIR,
         NIR_f = AMM_NIR_f,                                  
         ALBE_f = AMM_ALBE_f) %>%             
  mutate(Source = "AMM")  # Add 'Source' column for the AMM location

#str(EC_Tower_selected_AMM)

# Make sure the column names are consistent before merging
EC_Tower_selected_AMM <- EC_Tower_selected_AMM %>% rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_AMM, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 , SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f , WTMP_f ,WLEV_f , ATMP, ATMP_f ,TA_KNMI_270, PAIR ,PAIR_f ,PA_KNMI_270,  
         VPD_EP,  VPD_f ,  DTMP_f ,  WIND_f , WD_KNMI_270, WINS ,WINS_f ,SWIN_KNMI_270 , RAIN,RAIN_f ,RAIN_KNMI_270 ,  
         RHUM, RHUM_EP ,RHUM_f ,RH_KNMI_270,  NEE_CO2 ,NEE_CO2_MDS,  NEE_CH4 ,NEE_CH4_MDS , NEE_H2O , RECO_NT , SWIN_f  ,SWOT_f  ,  
         PAR ,PAR_f  , LWIN_f  ,  LWOT_f  ,  RNR_f , RPR_f , NIR_f  , ALBE_f ,  NDVI_f)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'AMR' location
EC_Tower_selected_AMR <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = AMR_SWCT_1_005,
         SWCT_3_005 = AMR_SWCT_3_005,
         SWCT_1_015 = AMR_SWCT_1_015,        
         STMP_1_005 = AMR_STMP_1_005,
         STMP_3_005 = AMR_STMP_3_005,
         STMP_1_015 = AMR_STMP_1_015,
         STMP_3_015 = AMR_STMP_3_015,
         SHF_1_f = AMR_SHF_1_f,
         SHF_2_f = AMR_SHF_2_f,                                                         
         WTMP_f = AMR_WTMP_f,                                      
         WLEV_f = AMR_WLEV_f,                                      
         ATMP = AMR_ATMP,
         ATMP_f = AMR_ATMP_f,
         TA_KNMI_270 = AMR_TA_KNMI_270,                 
         PAIR = AMR_PAIR,
         PAIR_f = AMR_PAIR_f,
         PA_KNMI_270 = AMR_PA_KNMI_270,                 
         VPD_EP = AMR_VPD_EP,
         VPD_f = AMR_VPD_f,                              
         DTMP_f  = AMR_DTMP_f,                                    
         WIND_f  = AMR_WIND_f,
         WD_KNMI_270 = AMR_WD_KNMI_270,                          
         WINS = AMR_WINS,
         WINS_f = AMR_WINS_f,
         SWIN_KNMI_270 = AMR_SWIN_KNMI_270,                  
         RAIN = AMR_RAIN,
         RAIN_f = AMR_RAIN_f,
         RAIN_KNMI_270 = AMR_RAIN_KNMI_270,                  
         RHUM = AMR_RHUM,
         RHUM_EP = AMR_RHUM_EP,
         RHUM_f = AMR_RHUM_f,
         RH_KNMI_270 = AMR_RH_KNMI_270,            
         NEE_CO2 = AMR_NEE_CO2,
         NEE_CO2_MDS = AMR_NEE_CO2_MDS,                         
         NEE_CH4 = AMR_NEE_CH4,
         NEE_CH4_MDS = AMR_NEE_CH4_MDS,                         
         NEE_H2O = AMR_NEE_CH4_MDS,                                     
         RECO_NT = AMR_RECO_NT,                                     
         SWIN_f = AMR_SWIN_f,                                      
         PAR = AMR_PAR,
         PAR_f = AMR_PAR_f,                                   
         LWIN_f = AMR_LWIN_f,
         NIR = AMR_NIR,
         NIR_f = AMR_NIR_f,                                  
         ALBE_f = AMR_ALBE_f) %>%             
  mutate(Source = "AMR")  # Add 'Source' column for the AMR location

#str(EC_Tower_selected_AMR)

# Make sure the column names are consistent before merging
EC_Tower_selected_AMR <- EC_Tower_selected_AMR %>%
  rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_AMR, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 ,SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f, WTMP_f, WLEV_f, ATMP, ATMP_f, TA_KNMI_270, PAIR, PAIR_f ,PA_KNMI_270,  
         VPD_EP, VPD_f, DTMP_f, WIND_f, WD_KNMI_270, WINS, WINS_f, SWIN_KNMI_270, RAIN,RAIN_f, RAIN_KNMI_270,  
         RHUM, RHUM_EP, RHUM_f, RH_KNMI_270, NEE_CO2, NEE_CO2_MDS, NEE_CH4, NEE_CH4_MDS, NEE_H2O, RECO_NT, SWIN_f, SWOT_f,  
         PAR, PAR_f, LWIN_f, LWOT_f, RNR_f, RPR_f, NIR_f, ALBE_f, NDVI_f)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'BUO' location
EC_Tower_selected_BUO <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = BUO_SWCT_1_005,
         SWCT_3_005 = BUO_SWCT_3_005,
         SWCT_1_015 = BUO_SWCT_1_015,        
         STMP_1_005 = BUO_STMP_1_005,
         STMP_3_005 = BUO_STMP_3_005,
         STMP_1_015 = BUO_STMP_1_015,
         STMP_3_015 = BUO_STMP_3_015,
         SHF_1_f = BUO_SHF_1_f,
         SHF_2_f = BUO_SHF_2_f,                                                         
         WTMP_f = BUO_WTMP_f,                                      
         WLEV_f = BUO_WLEV_f,                                      
         ATMP = BUO_ATMP,
         ATMP_f = BUO_ATMP_f,
         TA_KNMI_270 = BUO_TA_KNMI_270,                 
         PAIR = BUO_PAIR,
         PAIR_f = BUO_PAIR_f,
         PA_KNMI_270 = BUO_PA_KNMI_270,                 
         VPD_EP = BUO_VPD_EP,
         VPD_f = BUO_VPD_f,                              
         DTMP_f  = BUO_DTMP_f,                                    
         WIND_f  = BUO_WIND_f,
         WD_KNMI_270 = BUO_WD_KNMI_270,                          
         WINS = BUO_WINS,
         WINS_f = BUO_WINS_f,
         SWIN_KNMI_270 = BUO_SWIN_KNMI_270,                  
         RAIN = BUO_RAIN,
         RAIN_f = BUO_RAIN_f,
         RAIN_KNMI_270 = BUO_RAIN_KNMI_270,                  
         RHUM = BUO_RHUM,
         RHUM_EP = BUO_RHUM_EP,
         RHUM_f = BUO_RHUM_f,
         RH_KNMI_270 = BUO_RH_KNMI_270,            
         NEE_CO2 = BUO_NEE_CO2,
         NEE_CO2_MDS = BUO_NEE_CO2_MDS,                         
         NEE_CH4 = BUO_NEE_CH4,
         NEE_CH4_MDS = BUO_NEE_CH4_MDS,                         
         NEE_H2O = BUO_NEE_CH4_MDS,                                     
         RECO_NT = BUO_RECO_NT,                                     
         SWIN_f = BUO_SWIN_f,                                      
         PAR = BUO_PAR,
         PAR_f = BUO_PAR_f,                                   
         LWIN_f = BUO_LWIN_f,
         NIR = BUO_NIR,
         NIR_f = BUO_NIR_f,                                  
         ALBE_f = BUO_ALBE_f) %>%             
  mutate(Source = "BUO")   # Add 'Source' column for the BUO location

#str(EC_Tower_selected_BUO)

# Make sure the column names are consistent before merging
EC_Tower_selected_BUO <- EC_Tower_selected_BUO %>%
  rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_BUO, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 ,SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f, WTMP_f, WLEV_f, ATMP, ATMP_f, TA_KNMI_270, PAIR, PAIR_f ,PA_KNMI_270,  
         VPD_EP, VPD_f, DTMP_f, WIND_f, WD_KNMI_270, WINS, WINS_f, SWIN_KNMI_270, RAIN,RAIN_f, RAIN_KNMI_270,  
         RHUM, RHUM_EP, RHUM_f, RH_KNMI_270, NEE_CO2, NEE_CO2_MDS, NEE_CH4, NEE_CH4_MDS, NEE_H2O, RECO_NT, SWIN_f, SWOT_f,  
         PAR, PAR_f, LWIN_f, LWOT_f, RNR_f, RPR_f, NIR_f, ALBE_f, NDVI_f)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'BUW' location
EC_Tower_selected_BUW <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = BUW_SWCT_1_005,
         SWCT_3_005 = BUW_SWCT_3_005,
         SWCT_1_015 = BUW_SWCT_1_015,        
         STMP_1_005 = BUW_STMP_1_005,
         STMP_3_005 = BUW_STMP_3_005,
         STMP_1_015 = BUW_STMP_1_015,
         STMP_3_015 = BUW_STMP_3_015,
         SHF_1_f = BUW_SHF_1_f,
         SHF_2_f = BUW_SHF_2_f,                                                         
         WTMP_f = BUW_WTMP_f,                                      
         WLEV_f = BUW_WLEV_f,                                      
         ATMP = BUW_ATMP,
         ATMP_f = BUW_ATMP_f,
         TA_KNMI_270 = BUW_TA_KNMI_270,                 
         PAIR = BUW_PAIR,
         PAIR_f = BUW_PAIR_f,
         PA_KNMI_270 = BUW_PA_KNMI_270,                 
         VPD_EP = BUW_VPD_EP,
         VPD_f = BUW_VPD_f,                              
         DTMP_f  = BUW_DTMP_f,                                    
         WIND_f  = BUW_WIND_f,
         WD_KNMI_270 = BUW_WD_KNMI_270,                          
         WINS = BUW_WINS,
         WINS_f = BUW_WINS_f,
         SWIN_KNMI_270 = BUW_SWIN_KNMI_270,                  
         RAIN = BUW_RAIN,
         RAIN_f = BUW_RAIN_f,
         RAIN_KNMI_270 = BUW_RAIN_KNMI_270,                  
         RHUM = BUW_RHUM,
         RHUM_EP = BUW_RHUM_EP,
         RHUM_f = BUW_RHUM_f,
         RH_KNMI_270 = BUW_RH_KNMI_270,            
         NEE_CO2 = BUW_NEE_CO2,
         NEE_CO2_MDS = BUW_NEE_CO2_MDS,                         
         NEE_CH4 = BUW_NEE_CH4,
         NEE_CH4_MDS = BUW_NEE_CH4_MDS,                         
         NEE_H2O = BUW_NEE_CH4_MDS,                                     
         RECO_NT = BUW_RECO_NT,                                     
         SWIN_f = BUW_SWIN_f,                                      
         PAR = BUW_PAR,
         PAR_f = BUW_PAR_f,                                   
         LWIN_f = BUW_LWIN_f,
         NIR = BUW_NIR,
         NIR_f = BUW_NIR_f,                                  
         ALBE_f = BUW_ALBE_f) %>%             
  mutate(Source = "BUW")  # Add 'Source' column for the BUW location

#str(EC_Tower_selected_BUW)

# Make sure the column names are consistent before merging
EC_Tower_selected_BUW <- EC_Tower_selected_BUW %>%
  rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_BUW, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 ,SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f, WTMP_f, WLEV_f, ATMP, ATMP_f, TA_KNMI_270, PAIR, PAIR_f ,PA_KNMI_270,  
         VPD_EP, VPD_f, DTMP_f, WIND_f, WD_KNMI_270, WINS, WINS_f, SWIN_KNMI_270, RAIN,RAIN_f, RAIN_KNMI_270,  
         RHUM, RHUM_EP, RHUM_f, RH_KNMI_270, NEE_CO2, NEE_CO2_MDS, NEE_CH4, NEE_CH4_MDS, NEE_H2O, RECO_NT, SWIN_f, SWOT_f,  
         PAR, PAR_f, LWIN_f, LWOT_f, RNR_f, RPR_f, NIR_f, ALBE_f, NDVI_f)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'HOC' location
EC_Tower_selected_HOC <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = HOC_SWCT_1_005,
         SWCT_3_005 = HOC_SWCT_3_005,
         SWCT_1_015 = HOC_SWCT_1_015,        
         STMP_1_005 = HOC_STMP_1_005,
         STMP_3_005 = HOC_STMP_3_005,
         STMP_1_015 = HOC_STMP_1_015,
         STMP_3_015 = HOC_STMP_3_015,
         SHF_1_f = HOC_SHF_1_f,
         SHF_2_f = HOC_SHF_2_f,                                                         
         WTMP_f = HOC_WTMP_f,                                      
         WLEV_f = HOC_WLEV_f,                                      
         ATMP = HOC_ATMP,
         ATMP_f = HOC_ATMP_f,
         TA_KNMI_270 = HOC_TA_KNMI_270,                 
         PAIR = HOC_PAIR,
         PAIR_f = HOC_PAIR_f,
         PA_KNMI_270 = HOC_PA_KNMI_270,                 
         VPD_EP = HOC_VPD_EP,
         VPD_f = HOC_VPD_f,                              
         DTMP_f  = HOC_DTMP_f,                                    
         WIND_f  = HOC_WIND_f,
         WD_KNMI_270 = HOC_WD_KNMI_270,                          
         WINS = HOC_WINS,
         WINS_f = HOC_WINS_f,
         SWIN_KNMI_270 = HOC_SWIN_KNMI_270,                  
         RAIN = HOC_RAIN,
         RAIN_f = HOC_RAIN_f,
         RAIN_KNMI_270 = HOC_RAIN_KNMI_270,                  
         RHUM = HOC_RHUM,
         RHUM_EP = HOC_RHUM_EP,
         RHUM_f = HOC_RHUM_f,
         RH_KNMI_270 = HOC_RH_KNMI_270,            
         NEE_CO2 = HOC_NEE_CO2,
         NEE_CO2_MDS = HOC_NEE_CO2_MDS,                         
         NEE_CH4 = HOC_NEE_CH4,
         NEE_CH4_MDS = HOC_NEE_CH4_MDS,                         
         NEE_H2O = HOC_NEE_CH4_MDS,                                     
         RECO_NT = HOC_RECO_NT,                                     
         SWIN_f = HOC_SWIN_f,                                      
         PAR = HOC_PAR,
         PAR_f = HOC_PAR_f,                                   
         LWIN_f = HOC_LWIN_f,
         NIR = HOC_NIR,
         NIR_f = HOC_NIR_f,                                  
         ALBE_f = HOC_ALBE_f) %>%             
  mutate(Source = "HOC")  # Add 'Source' column for the HOC location

#str(EC_Tower_selected_HOC)

# Make sure the column names are consistent before merging
EC_Tower_selected_HOC <- EC_Tower_selected_HOC %>%
  rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_HOC, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 ,SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f, WTMP_f, WLEV_f, ATMP, ATMP_f, TA_KNMI_270, PAIR, PAIR_f ,PA_KNMI_270,  
         VPD_EP, VPD_f, DTMP_f, WIND_f, WD_KNMI_270, WINS, WINS_f, SWIN_KNMI_270, RAIN,RAIN_f, RAIN_KNMI_270,  
         RHUM, RHUM_EP, RHUM_f, RH_KNMI_270, NEE_CO2, NEE_CO2_MDS, NEE_CH4, NEE_CH4_MDS, NEE_H2O, RECO_NT, SWIN_f, SWOT_f,  
         PAR, PAR_f, LWIN_f, LWOT_f, RNR_f, RPR_f, NIR_f, ALBE_f, NDVI_f)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'HOH' location
EC_Tower_selected_HOH <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = HOH_SWCT_1_005,
         SWCT_3_005 = HOH_SWCT_3_005,
         SWCT_1_015 = HOH_SWCT_1_015,        
         STMP_1_005 = HOH_STMP_1_005,
         STMP_3_005 = HOH_STMP_3_005,
         STMP_1_015 = HOH_STMP_1_015,
         STMP_3_015 = HOH_STMP_3_015,
         SHF_1_f = HOH_SHF_1_f,
         SHF_2_f = HOH_SHF_2_f,                                                         
         WTMP_f = HOH_WTMP_f,                                      
         WLEV_f = HOH_WLEV_f,                                      
         ATMP = HOH_ATMP,
         ATMP_f = HOH_ATMP_f,
         TA_KNMI_270 = HOH_TA_KNMI_270,                 
         PAIR = HOH_PAIR,
         PAIR_f = HOH_PAIR_f,
         PA_KNMI_270 = HOH_PA_KNMI_270,                 
         VPD_EP = HOH_VPD_EP,
         VPD_f = HOH_VPD_f,                              
         DTMP_f  = HOH_DTMP_f,                                    
         WIND_f  = HOH_WIND_f,
         WD_KNMI_270 = HOH_WD_KNMI_270,                          
         WINS = HOH_WINS,
         WINS_f = HOH_WINS_f,
         SWIN_KNMI_270 = HOH_SWIN_KNMI_270,                  
         RAIN = HOH_RAIN,
         RAIN_f = HOH_RAIN_f,
         RAIN_KNMI_270 = HOH_RAIN_KNMI_270,                  
         RHUM = HOH_RHUM,
         RHUM_EP = HOH_RHUM_EP,
         RHUM_f = HOH_RHUM_f,
         RH_KNMI_270 = HOH_RH_KNMI_270,            
         NEE_CO2 = HOH_NEE_CO2,
         NEE_CO2_MDS = HOH_NEE_CO2_MDS,                         
         NEE_CH4 = HOH_NEE_CH4,
         NEE_CH4_MDS = HOH_NEE_CH4_MDS,                         
         NEE_H2O = HOH_NEE_CH4_MDS,                                     
         RECO_NT = HOH_RECO_NT,                                     
         SWIN_f = HOH_SWIN_f,                                      
         PAR = HOH_PAR,
         PAR_f = HOH_PAR_f,                                   
         LWIN_f = HOH_LWIN_f,
         NIR = HOH_NIR,
         NIR_f = HOH_NIR_f,                                  
         ALBE_f = HOH_ALBE_f) %>%             
  mutate(Source = "HOH")  # Add 'Source' column for the HOC location

#str(EC_Tower_selected_HOH)

# Make sure the column names are consistent before merging
EC_Tower_selected_HOH <- EC_Tower_selected_HOH %>%
  rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_HOH, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 ,SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f, WTMP_f, WLEV_f, ATMP, ATMP_f, TA_KNMI_270, PAIR, PAIR_f ,PA_KNMI_270,  
         VPD_EP, VPD_f, DTMP_f, WIND_f, WD_KNMI_270, WINS, WINS_f, SWIN_KNMI_270, RAIN,RAIN_f, RAIN_KNMI_270,  
         RHUM, RHUM_EP, RHUM_f, RH_KNMI_270, NEE_CO2, NEE_CO2_MDS, NEE_CH4, NEE_CH4_MDS, NEE_H2O, RECO_NT, SWIN_f, SWOT_f,  
         PAR, PAR_f, LWIN_f, LWOT_f, RNR_f, RPR_f, NIR_f, ALBE_f, NDVI_f)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'LDC' location
EC_Tower_selected_LDC <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = LDC_SWCT_1_005,
         SWCT_3_005 = LDC_SWCT_3_005,
         SWCT_1_015 = LDC_SWCT_1_015,        
         STMP_1_005 = LDC_STMP_1_005,
         STMP_3_005 = LDC_STMP_3_005,
         STMP_1_015 = LDC_STMP_1_015,
         STMP_3_015 = LDC_STMP_3_015,
         SHF_1_f = LDC_SHF_1_f,
         SHF_2_f = LDC_SHF_2_f,                                                         
         WTMP_f = LDC_WTMP_f,                                      
         WLEV_f = LDC_WLEV_f,                                      
         ATMP = LDC_ATMP,
         ATMP_f = LDC_ATMP_f,
         TA_KNMI_270 = LDC_TA_KNMI_270,                 
         PAIR = LDC_PAIR,
         PAIR_f = LDC_PAIR_f,
         PA_KNMI_270 = LDC_PA_KNMI_270,                 
         VPD_EP = LDC_VPD_EP,
         VPD_f = LDC_VPD_f,                              
         DTMP_f  = LDC_DTMP_f,                                    
         WIND_f  = LDC_WIND_f,
         WD_KNMI_270 = LDC_WD_KNMI_270,                          
         WINS = LDC_WINS,
         WINS_f = LDC_WINS_f,
         SWIN_KNMI_270 = LDC_SWIN_KNMI_270,                  
         RAIN = LDC_RAIN,
         RAIN_f = LDC_RAIN_f,
         RAIN_KNMI_270 = LDC_RAIN_KNMI_270,                  
         RHUM = LDC_RHUM,
         RHUM_EP = LDC_RHUM_EP,
         RHUM_f = LDC_RHUM_f,
         RH_KNMI_270 = LDC_RH_KNMI_270,            
         NEE_CO2 = LDC_NEE_CO2,
         NEE_CO2_MDS = LDC_NEE_CO2_MDS,                         
         NEE_CH4 = LDC_NEE_CH4,
         NEE_CH4_MDS = LDC_NEE_CH4_MDS,                         
         NEE_H2O = LDC_NEE_CH4_MDS,                                     
         RECO_NT = LDC_RECO_NT,                                     
         SWIN_f = LDC_SWIN_f,                                      
         PAR = LDC_PAR,
         PAR_f = LDC_PAR_f,                                   
         LWIN_f = LDC_LWIN_f,
         NIR = LDC_NIR,
         NIR_f = LDC_NIR_f,                                  
         ALBE_f = LDC_ALBE_f) %>%             
  mutate(Source = "LDC")  # Add 'Source' column for the LDH location

#str(EC_Tower_selected_LDC)

# Make sure the column names are consistent before merging
EC_Tower_selected_LDC <- EC_Tower_selected_LDC %>%
  rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_LDC, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 ,SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f, WTMP_f, WLEV_f, ATMP, ATMP_f, TA_KNMI_270, PAIR, PAIR_f ,PA_KNMI_270,  
         VPD_EP, VPD_f, DTMP_f, WIND_f, WD_KNMI_270, WINS, WINS_f, SWIN_KNMI_270, RAIN,RAIN_f, RAIN_KNMI_270,  
         RHUM, RHUM_EP, RHUM_f, RH_KNMI_270, NEE_CO2, NEE_CO2_MDS, NEE_CH4, NEE_CH4_MDS, NEE_H2O, RECO_NT, SWIN_f, SWOT_f,  
         PAR, PAR_f, LWIN_f, LWOT_f, RNR_f, RPR_f, NIR_f, ALBE_f, NDVI_f)

#------------------------------------------------------------------------------
# Filter and rename relevant columns for the 'LDH' location
EC_Tower_selected_LDH <- EC_Tower_Data_file %>%
  select(date,
         SWCT_1_005 = LDH_SWCT_1_005,
         SWCT_3_005 = LDH_SWCT_3_005,
         SWCT_1_015 = LDH_SWCT_1_015,        
         STMP_1_005 = LDH_STMP_1_005,
         STMP_3_005 = LDH_STMP_3_005,
         STMP_1_015 = LDH_STMP_1_015,
         STMP_3_015 = LDH_STMP_3_015,
         SHF_1_f = LDH_SHF_1_f,
         SHF_2_f = LDH_SHF_2_f,                                                         
         WTMP_f = LDH_WTMP_f,                                      
         WLEV_f = LDH_WLEV_f,                                      
         ATMP = LDH_ATMP,
         ATMP_f = LDH_ATMP_f,
         TA_KNMI_270 = LDH_TA_KNMI_270,                 
         PAIR = LDH_PAIR,
         PAIR_f = LDH_PAIR_f,
         PA_KNMI_270 = LDH_PA_KNMI_270,                 
         VPD_EP = LDH_VPD_EP,
         VPD_f = LDH_VPD_f,                              
         DTMP_f  = LDH_DTMP_f,                                    
         WIND_f  = LDH_WIND_f,
         WD_KNMI_270 = LDH_WD_KNMI_270,                          
         WINS = LDH_WINS,
         WINS_f = LDH_WINS_f,
         SWIN_KNMI_270 = LDH_SWIN_KNMI_270,                  
         RAIN = LDH_RAIN,
         RAIN_f = LDH_RAIN_f,
         RAIN_KNMI_270 = LDH_RAIN_KNMI_270,                  
         RHUM = LDH_RHUM,
         RHUM_EP = LDH_RHUM_EP,
         RHUM_f = LDH_RHUM_f,
         RH_KNMI_270 = LDH_RH_KNMI_270,            
         NEE_CO2 = LDH_NEE_CO2,
         NEE_CO2_MDS = LDH_NEE_CO2_MDS,                         
         NEE_CH4 = LDH_NEE_CH4,
         NEE_CH4_MDS = LDH_NEE_CH4_MDS,                         
         NEE_H2O = LDH_NEE_CH4_MDS,                                     
         RECO_NT = LDH_RECO_NT,                                     
         SWIN_f = LDH_SWIN_f,                                      
         PAR = LDH_PAR,
         PAR_f = LDH_PAR_f,                                   
         LWIN_f = LDH_LWIN_f,
         NIR = LDH_NIR,
         NIR_f = LDH_NIR_f,                                  
         ALBE_f = LDH_ALBE_f) %>%             
  mutate(Source = "LDH")  # Add 'Source' column for the LDH location

#str(EC_Tower_selected_LDH)

# Make sure the column names are consistent before merging
EC_Tower_selected_LDH <- EC_Tower_selected_LDH %>%
  rename(Date = date)

# Perform the left join with EC_Tower_Merged_Final
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  left_join(EC_Tower_selected_LDH, by = c("Date", "Source"))

# Use coalesce to update SWCT, Tsoil, and NEE_CO2
EC_Tower_Merged_Final <- EC_Tower_Merged_Final %>%
  mutate(SWCT_1_005 = coalesce(SWCT_1_005.x, SWCT_1_005.y),
         SWCT_3_005 = coalesce(SWCT_3_005.x, SWCT_3_005.y),
         SWCT_1_015 = coalesce(SWCT_1_015.x, SWCT_1_015.y),       
         STMP_1_005 = coalesce(STMP_1_005.x, STMP_1_005.y),
         STMP_3_005 = coalesce(STMP_3_005.x, STMP_3_005.y),
         STMP_1_015 = coalesce(STMP_1_015.x, STMP_1_015.y),
         STMP_3_015 = coalesce(STMP_3_015.x, STMP_3_015.y),
         SHF_1_f    = coalesce(SHF_1_f.x, SHF_1_f.y),
         SHF_2_f    = coalesce(SHF_2_f.x, SHF_2_f.y),                                                          
         WTMP_f     = coalesce(WTMP_f.x, WTMP_f.y),                                       
         WLEV_f     = coalesce(WLEV_f.x, WLEV_f.y),                                      
         ATMP       = coalesce(ATMP.x, ATMP.y), 
         ATMP_f     = coalesce(ATMP_f.x, ATMP_f.y), 
         TA_KNMI_270= coalesce(TA_KNMI_270.x, TA_KNMI_270.y),                  
         PAIR       = coalesce(PAIR.x, PAIR.y), 
         PAIR_f     = coalesce(PAIR_f.x, PAIR_f.y),
         PA_KNMI_270 = coalesce(PA_KNMI_270.x, PA_KNMI_270.y),                  
         VPD_EP      = coalesce(VPD_EP.x, VPD_EP.y), 
         VPD_f       = coalesce(VPD_f.x, VPD_f.y),                                
         DTMP_f      = coalesce(DTMP_f.x, DTMP_f.y),                                    
         WIND_f      = coalesce(WIND_f.x, WIND_f.y),
         WD_KNMI_270 = coalesce(WD_KNMI_270.x, WD_KNMI_270.y),                           
         WINS        = coalesce(WINS.x, WINS.y),
         WINS_f      = coalesce(WINS_f.x, WINS_f.y),
         SWIN_KNMI_270 =  coalesce(SWIN_KNMI_270.x, SWIN_KNMI_270.y),                 
         RAIN       = coalesce(RAIN.x, RAIN.y),
         RAIN_f     = coalesce(RAIN_f.x, RAIN_f.y),
         RAIN_KNMI_270 = coalesce(RAIN_KNMI_270.x, RAIN_KNMI_270.y),                  
         RHUM      = coalesce(RHUM.x, RHUM.y),
         RHUM_EP   = coalesce(RHUM_EP.x, RHUM_EP.y),
         RHUM_f    = coalesce(RHUM_f.x, RHUM_f.y),
         RH_KNMI_270 =   coalesce(RH_KNMI_270.x, RH_KNMI_270.y),         
         NEE_CO2   = coalesce(NEE_CO2.x, NEE_CO2.y),
         NEE_CO2_MDS = coalesce(NEE_CO2_MDS.x, NEE_CO2_MDS.y),                          
         NEE_CH4   = coalesce(NEE_CH4.x, NEE_CH4.y),
         NEE_CH4_MDS =  coalesce(NEE_CH4_MDS.x, NEE_CH4_MDS.y),                        
         NEE_H2O   =  coalesce(NEE_H2O.x, NEE_H2O.y),                                    
         RECO_NT   =  coalesce(RECO_NT.x, RECO_NT.y),                                    
         SWIN_f    = coalesce(SWIN_f.x, SWIN_f.y),                                      
         #SWOT_f    =  coalesce(SWOT_f.x, SWOT_f.y),                                   
         PAR       = coalesce(PAR.x, PAR.y),
         PAR_f     = coalesce(PAR_f.x,PAR_f.y),                                   
         LWIN_f    = coalesce(LWIN_f.x, LWIN_f.y),                                    
         #LWOT_f    =  coalesce(LWOT_f.x, LWOT_f.y),                                   
         #RNR_f     =  coalesce(RNR_f.x, RNR_f.y),                                    
         #RPR_f     =   coalesce(RPR_f.x, RPR_f.y),                                     
         NIR_f     =  coalesce(NIR_f.x, NIR_f.y),                                 
         ALBE_f    = coalesce(ALBE_f.x, ALBE_f.y)) %>%
  select(Date, Source, S1_VSM, S1_Backscatter, Planet_SWC, Available_soil_storage_mm,
         S2_NDVI, S2_EVI, S2_NDMI, L8_9_LST,MODIS_LAI,
         SWCT_1_005, SWCT_3_005 ,SWCT_1_015, STMP_1_005, STMP_3_005, STMP_1_015, STMP_3_015, 
         SHF_1_f, SHF_2_f, WTMP_f, WLEV_f, ATMP, ATMP_f, TA_KNMI_270, PAIR, PAIR_f ,PA_KNMI_270,  
         VPD_EP, VPD_f, DTMP_f, WIND_f, WD_KNMI_270, WINS, WINS_f, SWIN_KNMI_270, RAIN,RAIN_f, RAIN_KNMI_270,  
         RHUM, RHUM_EP, RHUM_f, RH_KNMI_270, NEE_CO2, NEE_CO2_MDS, NEE_CH4, NEE_CH4_MDS, NEE_H2O, RECO_NT, SWIN_f, SWOT_f,  
         PAR, PAR_f, LWIN_f, LWOT_f, RNR_f, RPR_f, NIR_f, ALBE_f, NDVI_f)

# -----------------------------Add DOY to dataframe and export------------------ 
# Add a new column with the day of the year
EC_Tower_Merged_Final$Day_of_Year <- yday(EC_Tower_Merged_Final$Date)

str(EC_Tower_Merged_Final)
summary(EC_Tower_Merged_Final)
head(EC_Tower_Merged_Final)

write.csv(EC_Tower_Merged_Final, "C:/Data_MSc_Thesis/Pre_Processed_Data/Pre_Processed_Data_All_Locaions_Updated_2.csv", row.names = FALSE)
 #---------------------------
