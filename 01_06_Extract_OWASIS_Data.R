# HEADER
# File: 01_06_Extract_OWASIS_Data.R 
# Date: 2025
# Created by: Rob Alamgir  
# Version: 1.0
# References: 

# R version used: 4.3.2

#----------------------Import Relevant Packages---------------------
suppressMessages(suppressWarnings(require(raster)))    
suppressMessages(suppressWarnings(require(sf)))        
suppressMessages(suppressWarnings(require(sp)))        
suppressMessages(suppressWarnings(require(rgdal)))     
suppressMessages(suppressWarnings(require(dplyr)))     
suppressMessages(suppressWarnings(require(stringr)))  
suppressMessages(suppressWarnings(require(ggplot2)))  
suppressMessages(suppressWarnings(require(lubridate)))  

#----------------------Set WD and import data------------------------------------

#Set Working Directory
setwd("C:/Data_MSc_Thesis/OWASIS/OWASIS_friesland_data")

friesland_2020_files <- list.files(path="friesland_2020/", full.names=TRUE, pattern="*.tif")
friesland_2021_files <- list.files(path="friesland_2021/", full.names=TRUE, pattern="*.tif")
friesland_2022_files <- list.files(path="friesland_2022/", full.names=TRUE, pattern="*.tif")
friesland_2023_files <- list.files(path="friesland_2023/", full.names=TRUE, pattern="*.tif")

#----------------------Convert TIFF files to CSV files -------------------------
# Modify path and name when converting other raster data 

lapply(friesland_2023_files, function(x) {
  t <- raster(x)
  filename <- names(t)
  d <- cbind(coordinates(t), v = values(t))
  df <- as.data.frame(d)
  source_filename <- basename(t@file@name) # Extracting date from source instead of names
  name <- str_sub(source_filename, 64, 74) # Assuming the date is in the first 8 characters of the source filename
  date <- as.Date(name, format = "%Y-%m-%d") 
  df$date <- date
  names(df)[names(df) == "v"] <- "Available_soil_storage_mm"
  write.csv(df, file = paste0("friesland_CSV/", source_filename, ".csv"))
})
#----------------------Import and merge all CSV Files--------------------------
friesland_filename <- list.files("friesland_CSV/", pattern="*.tif.csv", full.names=TRUE, recursive=FALSE)
friesland_tables <- Map(cbind, lapply(friesland_filename, data.table::fread, sep=",")) 
friesland_table <- do.call(rbind, lapply(friesland_tables, subset))
friesland_table_df <- as.data.frame(friesland_table)
head(friesland_table_df, 5) 
summary(friesland_table_df)
str(friesland_table_df)

#----------------------Find the spatial extent of the EC Towers Location within one TIF File---------
raster_layer <- test_tif_file # Assuming you have the raster layer as 'test_tif_file'

#ALB_MS_point_lon <- 189540.226441059   
#ALB_MS_point_lat <- 563087.999400083

#ALB_RF_point_lon <- 189694.395452414
#ALB_RF_point_lat <- 563069.672616338

#AMM_point_lon <- 189636.423177042
#AMM_point_lat <- 560619.697916479

#AMR_point_lon <- 189601.248160121
#AMR_point_lat <- 560716.354951566	

#BUO_point_lon <- 187576.536420368
#BUO_point_lat <-	568258.526887753

#BUW_point_lon <- 186823.092788315
#BUW_point_lat <-	567797.35043408	
	
#HOC_point_lon <- 174330.361182139
#HOC_point_lat <- 555945.517109262

#HOH_point_lon <- 173892.297037333
#HOH_point_lat <-	555506.545819334

#LDC_point_lon <- 191973.977564074
#LDC_point_lat <-	562340.016584677

LDH_point_lon <- 192077.029630629
LDH_point_lat <-	562769.454469415	

# Define your x and y coordinates (EPSG:28992)
x_coord <- LDH_point_lon 
y_coord <- LDH_point_lat

# Extract raster information
extent_raster <- extent(raster_layer) # Extent
res <- res(raster_layer)              # Resolution

# Convert coordinates to cell indices
col_index <- floor((x_coord - extent_raster@xmin) / res[1]) + 1
row_index <- floor((extent_raster@ymax - y_coord) / res[2]) + 1

# Convert cell indices back to extent values
cell_x_min <- extent_raster@xmin + (col_index - 1) * res[1]
cell_x_max <- extent_raster@xmin + col_index * res[1]
cell_y_min <- extent_raster@ymax - (row_index * res[2])
cell_y_max <- extent_raster@ymax - ((row_index - 1) * res[2])

# Display the extent values
cat("Cell Extent Coordinates:\n")
cat("X Min:", cell_x_min, "\n")
cat("X Max:", cell_x_max, "\n")
cat("Y Min:", cell_y_min, "\n")
cat("Y Max:", cell_y_max, "\n")

#----------------------Use the Extent Range Find the Exact Values--------------------

# Define the range
min_value <- 560500
max_value <- 560750 

# Filter rows where 'x' is between min_value and max_value
rows_with_values <- friesland_table_df %>%
  filter(between(y, min_value, max_value))

# Check if any rows were found
if (nrow(rows_with_values) > 0) {
  print(rows_with_values)
} else {
  print("No rows found ")
}

#str(rows_with_values)
summary(rows_with_values)

#----------------------Filter Dataframes Based on Spatial Extent Points and Export CSVs--------------------

ALB_MS_filtered_df <- friesland_table_df[friesland_table_df$x == 189625 & friesland_table_df$y == 563125, ]
str(ALB_MS_filtered_df)
summary(ALB_MS_filtered_df)
#write.csv(ALB_MS_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\ALB_MS_OWASIS.csv", row.names=FALSE)

ggplot(ALB_MS_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


ALB_RF_filtered_df <- friesland_table_df[friesland_table_df$x == 189625 & friesland_table_df$y == 563125, ]
str(ALB_RF_filtered_df)
summary(ALB_RF_filtered_df)
#write.csv(ALB_RF_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\ALB_RF_OWASIS.csv", row.names=FALSE)

ggplot(ALB_RF_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


AMM_filtered_df <- friesland_table_df[friesland_table_df$x == 189625 & friesland_table_df$y == 560625, ]
str(AMM_filtered_df)
summary(AMM_filtered_df)
#write.csv(AMM_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\AMM_OWASIS.csv", row.names=FALSE)

ggplot(AMM_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


AMR_filtered_df <- friesland_table_df[friesland_table_df$x == 189625 & friesland_table_df$y == 560625, ]
str(AMR_filtered_df)
summary(AMR_filtered_df)
#write.csv(AMR_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\AMR_OWASIS.csv", row.names=FALSE)

ggplot(AMR_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


BUO_filtered_df <- friesland_table_df[friesland_table_df$x == 187625 & friesland_table_df$y == 568375, ]
str(BUO_filtered_df)
summary(BUO_filtered_df)
#write.csv(BUO_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\BUO_OWASIS.csv", row.names=FALSE)

ggplot(BUO_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


BUW_filtered_df <- friesland_table_df[friesland_table_df$x == 186875 & friesland_table_df$y == 567875, ]
str(BUW_filtered_df)
summary(BUW_filtered_df)
#write.csv(BUW_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\BUW_OWASIS.csv", row.names=FALSE)

ggplot(BUW_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


HOC_filtered_df <- friesland_table_df[friesland_table_df$x == 174375 & friesland_table_df$y == 555875, ]
str(HOC_filtered_df)
summary(HOC_filtered_df)
#write.csv(HOC_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\HOC_OWASIS.csv", row.names=FALSE)

ggplot(HOC_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


HOH_filtered_df <- friesland_table_df[friesland_table_df$x == 174375 & friesland_table_df$y == 555875, ]
str(HOH_filtered_df)
summary(HOH_filtered_df)
#write.csv(HOH_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\HOH_OWASIS.csv", row.names=FALSE)

ggplot(HOH_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


LDC_filtered_df <- friesland_table_df[friesland_table_df$x == 191875 & friesland_table_df$y == 562375, ]
str(LDC_filtered_df)
summary(LDC_filtered_df)
#write.csv(LDC_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\LDC_OWASIS.csv", row.names=FALSE)

ggplot(LDC_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))


LDH_filtered_df <- friesland_table_df[friesland_table_df$x == 192125 & friesland_table_df$y == 562875, ]
str(LDH_filtered_df)
summary(LDH_filtered_df)
#write.csv(LDH_filtered_df, "C:\\Data_MSc_Thesis\\OWASIS\\EC_Tower_OWASIS_Data\\LDH_OWASIS.csv", row.names=FALSE)

ggplot(LDH_filtered_df) +
  geom_point(aes(x = date, y = Available_soil_storage_mm))

#----------------------


