# HEADER
# File: 01_Pre_Processing_Merge_Selected_EC_Tower_Data.R
# Date: 2025
# Created by: Rob Alamgir  
# Version: 1.0
# R version used: 4.3.2

#--------------------------------Import relevant packages--------------------------------------------------------
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

#--------------------------------Import all the CSV files----------------------------------------------------------
# List CSV files with the specified pattern
EC_TOWER_CSV_Files <- list.files(path = "C:/Data_MSc_Thesis/EC_Tower_Data/Friesland_EC_Tower_Data_Selected_Data", 
                                 full.names = TRUE, pattern = "*.csv") #import EC_Tower data
print(EC_TOWER_CSV_Files)

# Loop through each file, load it, and assign the dataframe name based on the file name
for (file in EC_TOWER_CSV_Files) {
  df_name <- gsub("\\.csv$", "", basename(file)) # Extract the base name without the file extension
  df <- read.csv(file) # Load the csv file
  assign(df_name, df) # Assign the dataframe to the corresponding variable name
}

#--------------------------------Convert the formats of the columns---------------------------------------
# List of all loaded data frame names
df_names <- c("ALB_MS_df", "ALB_RF_df", "AMM_df", "AMR_df", 
              "BUO_df", "BUW_df", "HOC_df", "HOH_df", 
              "LDC_df", "LDH_df")

# Function to convert the columns in each data frame
convert_columns <- function(df) {
  # Convert datetime to POSIXct format
  if ("datetime" %in% names(df)) {
    df$datetime <- as.POSIXct(df$datetime, format = "%Y-%m-%d %H:%M:%S")
  }
  # Convert date to Date format
  if ("date" %in% names(df)) {
    df$date <- as.Date(df$date, format = "%Y-%m-%d")
  }
  # Convert all other columns to numeric, skipping datetime and date columns
  for (col in names(df)) {
    if (!(col %in% c("datetime", "date", "time"))) {
      df[[col]] <- as.numeric(df[[col]])
    }
  }
  return(df)
}

# Loop through each data frame and apply the conversion function
for (df_name in df_names) {
  df <- get(df_name)  # Get the data frame by name
  df <- convert_columns(df)  # Convert the columns
  assign(df_name, df)  # Reassign the modified data frame
}

# str(ALB_MS_df)
# summary(ALB_MS_df)
# str(ALB_RF_df)
# summary(ALB_RF_df)
# str(AMM_df)
# summary(AMM_df)
# str(AMR_df)
# summary(AMR_df)
# str(BUO_df)
# summary(BUO_df)
# str(BUW_df)
# summary(BUW_df)
# str(HOC_df)
# summary(HOC_df)
# str(HOH_df)
# summary(HOH_df)
# str(LDC_df)
# summary(LDC_df)
# str(LDH_df)
# summary(LDH_df)

#--------------------------------Compute Daily Mean of all Columns-----------------------------

ALB_MS_daily_means <- ALB_MS_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
ALB_MS_daily_means <- as.data.frame(ALB_MS_daily_means)
# Replace NaN values with NA in the dataframe
ALB_MS_daily_means[] <- lapply(ALB_MS_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

ALB_RF_daily_means <- ALB_RF_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
ALB_RF_daily_means <- as.data.frame(ALB_RF_daily_means)
ALB_RF_daily_means[] <- lapply(ALB_RF_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

AMM_daily_means <- AMM_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
AMM_daily_means <- as.data.frame(AMM_daily_means)
AMM_daily_means[] <- lapply(AMM_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})


AMR_daily_means <- AMR_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
AMR_daily_means <- as.data.frame(AMR_daily_means)
AMR_daily_means[] <- lapply(AMR_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

BUO_daily_means <- BUO_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
BUO_daily_means <- as.data.frame(BUO_daily_means)
BUO_daily_means[] <- lapply(BUO_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

BUW_daily_means <- BUW_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
BUW_daily_means <- as.data.frame(BUW_daily_means)
BUW_daily_means[] <- lapply(BUW_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

HOC_daily_means <- HOC_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
HOC_daily_means <- as.data.frame(HOC_daily_means)
HOC_daily_means[] <- lapply(HOC_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

HOH_daily_means <- HOH_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
HOH_daily_means <- as.data.frame(HOH_daily_means)
HOH_daily_means[] <- lapply(HOH_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

LDC_daily_means <- LDC_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
LDC_daily_means <- as.data.frame(LDC_daily_means)
LDC_daily_means[] <- lapply(LDC_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

LDH_daily_means <- LDH_df %>%
  group_by(date) %>%
  summarize(across(-c(datetime, time), ~ mean(.x, na.rm = TRUE))) %>%
  select(-DOY)
LDH_daily_means <- as.data.frame(LDH_daily_means)
LDH_daily_means[] <- lapply(LDH_daily_means, function(x) {
  if (is.numeric(x)) {
    x[is.nan(x)] <- NA
  }
  return(x)
})

str(ALB_MS_daily_means)
summary(ALB_MS_daily_means)
str(ALB_RF_daily_means)
summary(ALB_RF_daily_means)
str(AMM_daily_means)
summary(AMM_daily_means)
str(AMR_daily_means)
summary(AMR_daily_means)
str(BUO_daily_means)
summary(BUO_daily_means)
str(BUW_daily_means)
summary(BUW_daily_means)
str(HOC_daily_means)
summary(HOC_daily_means)
str(HOH_daily_means)
summary(HOH_daily_means)
str(LDC_daily_means)
summary(LDC_daily_means)
str(LDH_daily_means)
summary(LDH_daily_means)

#--------------------------------Merge Dataframes and export merged data-----------------
merged_df <- full_join(ALB_MS_daily_means, ALB_RF_daily_means,by=c("date"))
merged_df_1 <- full_join(merged_df, AMM_daily_means,by=c("date"))
merged_df_2 <- full_join(merged_df_1, AMR_daily_means,by=c("date"))
merged_df_3 <- full_join(merged_df_2, BUO_daily_means,by=c("date"))
merged_df_4 <- full_join(merged_df_3, BUW_daily_means,by=c("date"))
merged_df_5 <- full_join(merged_df_4, HOC_daily_means,by=c("date"))
merged_df_6 <- full_join(merged_df_5, HOH_daily_means,by=c("date"))
merged_df_7 <- full_join(merged_df_6, LDC_daily_means,by=c("date"))
merged_df_8 <- full_join(merged_df_7, LDH_daily_means,by=c("date"))

str(merged_df_8)
summary(merged_df_8)

write.csv(merged_df_8, "C:\\Data_MSc_Thesis\\EC_Tower_Data\\EC_Tower_Data_Daily_Mean_updated.csv", row.names=FALSE)

#--------------------------------