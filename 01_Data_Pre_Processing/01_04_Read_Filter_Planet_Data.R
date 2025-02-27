# HEADER
# File: 01_04_Read_Filter_Planet_Data.R
# Date: 2025
# Created by: Rob Alamgir  
# Version: 1.0

# R version used: 4.3.2
#---------------------------Import relevant packages----------------------------------------------------------------------
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

#---------------------------Import ncdf4 files--------------------------------------------------------
setwd("C:/Data_MSc_Thesis/Planet/SWC_Rob") #Set Working Directory

#Open nc file with ncdf4 

#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/ALB.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/AMM.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/ANK_PT.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/ASD_MP.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/BU.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/CAM.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/DEM.nc")
ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/HO.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/ILP_PT.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/LAW.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/LD.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/ONL.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/WRW.nc")
#ncfile <- nc_open("C:/Data_MSc_Thesis/Planet/SWC_Rob/ZEG.nc")

print(ncfile) # Print summary of the file
#---------------------------Read the basic dimensions of the ncdf4 file---------------------------------------
lon <- ncvar_get(ncfile, "x")
lat <- ncvar_get(ncfile, "y")
timestamp <- ncvar_get(ncfile, "timestamp")
timestamp_con <- as.POSIXct(timestamp, format="%Y%m%dT%H%M")
var <- ncvar_get(ncfile, "var")
source <- ncvar_get(ncfile, "source")
#---------------------------Plotting a heatmap of the SWC value for one specific timestamp -------------------
#Prep data to plot heatmap

#start = c(1, 1, 1, 1, 1): The starting indices for each dimension. 
#This indicates the position where the reading of data should begin for each dimension. 
#Here, it starts from the first element of each dimension.

#count = c(-1, -1, 1, 1, 1): The count of values to read along each dimension. 
#The value -1 indicates that all values along that dimension should be read, 
#while 1 indicates that only one value should be read from that dimension.

# Define and print the selected timestamp 
time_index <- 1  # Adjust this index as needed
timestamp_for_index <- timestamp_con[time_index]
print(timestamp_for_index) # Print the timestamp

# Read a part of the variable (e.g., first time step, first source)
heatmap_data <- ncvar_get(ncfile, "__xarray_dataarray_variable__", 
                  start = c(1, 1, time_index, 1, 1), 
                  count = c(-1, -1, 1, 1, 1))

dim(heatmap_data) # Check the dimensions of the extracted data
#length(lon) # Check the lengths of lon
#length(lat) # Check the lengths of lat

# Subset lon and lat to match the dimensions of the data
subset_lon <- lon[1:length(lon)] 
subset_lat <- lat[1:length(lat)]

# Create the data frame with the correct subsets
data_df <- data.frame(
  lon = rep(subset_lon, each = length(subset_lat)),
  lat = rep(subset_lat, times = length(subset_lon)),
  value = as.vector(heatmap_data)
)

# Check the first few rows to verify
#head(data_df)
#print(data_df)

# Create the heatmap
heatmap <- ggplot(data_df, aes(x = lon, y = lat, fill = value)) +
  geom_tile(na.rm = TRUE) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "SWC Heatmap of one timestep", x = "Lon", y = "Lat", fill = "SWC Value") +
  theme_minimal() +
  coord_fixed() 

heatmap

#---------------------------Plotting the location of the EC Tower over the heatmap----------
# ALB_MS  
#ALB_MS_point_lat <- 53.05356  
#ALB_MS_point_lon <- 5.902334   

#ALB_RF_point_lat <-	53.053385
#ALB_RF_point_lon <- 5.9046315

#AMM_point_lat <- 53.0313739	
#AMM_point_lon <- 5.9035053

#AMR_point_lat <- 53.0322447	
#AMR_point_lon <- 5.9029913

#ANK_PT_point_lat <-	52.2539163	
#ANK_PT_point_lon <- 5.0974712

#ASD_MP_point_lat <-	52.4752561	
#ASD_MP_point_lon <- 4.739599

#BUO_point_lat <-	53.1001428	
#BUO_point_lon <- 5.8735695

#BUW_point_lat <-	53.096044	
#BUW_point_lon <- 5.8622757

#CAM_point_lat <-	53.1549069	
#CAM_point_lon <- 6.5797653

#DEM_point_lat <-	52.2012984	
#DEM_point_lon <- 4.9461759

HOC_point_lat <-	52.9901389	
HOC_point_lon <- 5.6750753

#HOH_point_lat <-	52.9862098	
#HOH_point_lon <- 5.6685262

#ILP_PT_point_lat <-	52.44	
#ILP_PT_point_lon <- 4.944444

#LAW_MOB_point_lat <-	52.0364085
#LAW_MOB_point_lon <- 4.7918703

#LAW_MS_point_lat <-	52.0365695	
#LAW_MS_point_lon <- 4.7919222

#LDC_point_lat <-	53.0466767	
#LDC_point_lon <- 5.938544

#LDH_point_lat <-	53.0505284	
#LDH_point_lon <- 5.9401297

#ONL_point_lat <-	53.1766108	
#ONL_point_lon <- 6.5243032

#WRW_OW_point_lat <-	52.7227322
#WRW_OW_point_lon <-	6.0020717

#WRW_SR_point_lat <-	52.77202	
#WRW_SR_point_lon <- 5.9265035

#ZEG_MOB_point_lat <-	52.1363006	
#ZEG_MOB_point_lon <- 4.84006

#ZEG_PT_point_lat <-	52.1390418	
#ZEG_PT_point_lon <-4.838577

point_lat <- HOC_point_lat
point_lon <- HOC_point_lon

# Find the index in the latitude and longitude arrays that is closest to the point
lat_index <- as.numeric(which.min(abs(lat - point_lat)))
lon_index <- as.numeric(which.min(abs(lon - point_lon)))

# Print the indices
cat("Closest latitude index:", lat_index, "\n")
cat("Closest longitude index:", lon_index, "\n")

# Plot the point
heatmap +
  geom_point(aes(x = point_lon, y = point_lat), color = "red", size = 3)  # Overlay the point

#---------------------------Plotting timeseries of all SWC values within a specific coordinate------------------------------
# Read the variable for the specific x, y coordinate across all timestamps
TS_data <- ncvar_get(ncfile, "__xarray_dataarray_variable__", 
                  start = c(lon_index, lat_index, 1, 1, 1), 
                  count = c(1, 1, -1, 1, 1))

nc_close(ncfile) # Close the NetCDF file

time_series_df <- data.frame(timestamp = timestamp_con,value = TS_data) # Create a data frame for plotting
time_series_df$timestamp <- as.POSIXct(time_series_df$timestamp, format="%Y-%m-%d %H:%M:%S") # Convert the timestamp column to POSIXct (date-time) format

# Final Time Series (TS)
time_series_df_clean <- time_series_df %>%
  drop_na() %>% # Remove rows with NA values in any column
  rename(Planet_SWC=value) # Rename value column to Planet_SWC
  
head(time_series_df_clean)
tail(time_series_df_clean)
summary(time_series_df_clean)

#write.csv(time_series_df_clean, "C:\\Data_MSc_Thesis\\Planet\\NOBV_Planet_Inc_Data\\ZEG_PT_SWC_Planet.csv", row.names=FALSE)

#Plot timeseries
fig_TS <- ggplot(time_series_df_clean)+
  geom_point(aes(x = timestamp, y = Planet_SWC))+
  labs(title = "SWC Time Series of one specific coordinate ", x = "Date", y = "Mean Value") 

fig_TS


# Specify the date range
#start_date <- as.Date("2021-10-01")
#end_date <- as.Date("2024-06-30")

# Filter the dataframe by the date range
#filtered_df <- time_series_df %>%
#  filter(as.Date(timestamp) >= start_date & as.Date(timestamp) <= end_date)
#---------------------------
