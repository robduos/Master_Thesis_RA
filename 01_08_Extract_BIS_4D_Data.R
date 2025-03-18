# HEADER
# File: 01_08_Extract_BIS_4D_Data.R
# Date: 2025
# Created by: Rob Alamgir  
# Version: 1.0

# R version used: 4.3.2

#------------------------------import relevant packages & Set Working Directory-----------
suppressMessages(suppressWarnings(require(stars)))    
suppressMessages(suppressWarnings(require(ggplot2)))   
suppressMessages(suppressWarnings(require(ggspatial))) 
suppressMessages(suppressWarnings(require(cowplot)))   
suppressMessages(suppressWarnings(require(stringr)))   


# Set working directory to the location of your data files
setwd("C:/Data_MSc_Thesis/BIS_4D_Selected/") # Set Working Directory

#------------------------------import relevant data-----------------------------

# Define the directory containing the .tif files and list all .tif files in that directory
file_list <- list.files("C:/Data_MSc_Thesis/BIS_4D_Selected", pattern = "\\.tif$", full.names = TRUE)
print(file_list)  # Print the list of .tif files to verify the input

# Import the TIFF files as raster objects using the 'terra' package
raster_list <- lapply(file_list, rast)

# Optionally, assign descriptive names to the list elements for better readability
names(raster_list) <- c("BD_0_5", "BD_5_15", "Clay_0_5", "Clay_5_15", "SOM_2020_0_5", 
                        "SOM_2020_5_15", "SOM_2023_0_5", "SOM_2023_5_15")

# Check the imported raster objects to verify the data
raster_list

#------------------------------Load the NOBV Point data and create columns with reprojected X & Y data-----
# Load the point data, typically a CSV with coordinates
NOBV_Point_Data <- read.csv("C:/Data_MSc_Thesis/NOBV_Site_Data/NOBV_EC_Tower_Data_Final_CSV.csv")
head(NOBV_Point_Data)  # Show the first few rows to check the data

# Rename the columns to make them more understandable if necessary
names(NOBV_Point_Data)[names(NOBV_Point_Data) == "EPSG_4326_WGS_84_Longitude_X"] <- "Longitude"
names(NOBV_Point_Data)[names(NOBV_Point_Data) == "EPSG_4326_WGS_84.Latitude_Y"] <- "Latitude"

# Convert the data frame to a spatial object (simple feature) using the 'sf' package
point_sf <- st_as_sf(NOBV_Point_Data, coords = c("Longitude", "Latitude"), crs = 4326)

# Reproject the coordinates to match the raster's CRS (coordinate reference system)
# Here, we use a stereographic projection (EPSG:28992) as an example, you may need to adjust this depending on your data
point_reprojected <- st_transform(point_sf, 
                                  crs = "+proj=sterea +lat_0=52.1561605555556 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs")

# Extract the reprojected X and Y coordinates
reprojected_coords <- st_coordinates(point_reprojected)

# Add the reprojected coordinates as new columns to the original dataframe
NOBV_Point_Data <- NOBV_Point_Data %>%
  mutate(Reproj_X = reprojected_coords[, 1],  # Add the reprojected X coordinates
         Reproj_Y = reprojected_coords[, 2])  # Add the reprojected Y coordinates

head(NOBV_Point_Data) # View the updated data frame with reprojected coordinates

#------------------------------Extract the values from the raster files--------

# Initialize an empty list to store the extracted values for each raster
extracted_values_list <- list()

# Iterate over the raster_list and extract values for each raster
for (raster_name in names(raster_list)) {
  # Get the current raster object
  current_raster <- raster_list[[raster_name]]
  
  # Extract values from the raster based on the reprojected coordinates
  # The 'terra::extract' function takes the raster and the coordinates of points, extracting values from the raster at those points
  extracted_values <- terra::extract(current_raster, NOBV_Point_Data[, c("Reproj_X", "Reproj_Y")])
  
  # Store the extracted values in the list for later inspection
  extracted_values_list[[raster_name]] <- extracted_values
  
  # Add extracted values as a new column in the dataframe, with a name based on the raster's name
  NOBV_Point_Data[[paste(raster_name, "_values", sep = "")]] <- extracted_values
}


head(NOBV_Point_Data)
str(NOBV_Point_Data)

#------------------------------Export the cleaned data to a CSV file----------------------


# Rename Site_ID to Site_Identification first
NOBV_Point_Data <- NOBV_Point_Data %>%
  mutate(
    BD_0_5_values = BD_0_5_values$BD_gcm3_d_0_5_QRF_pred_mean,
    BD_5_15_values = BD_5_15_values$BD_gcm3_d_5_15_QRF_pred_mean,
    Clay_0_5_values = Clay_0_5_values$clay_per_d_0_5_QRF_pred_mean_processed,
    Clay_5_15_values = Clay_5_15_values$clay_per_d_5_15_QRF_pred_mean_processed,
    SOM_2020_0_5_values = SOM_2020_0_5_values$layer,
    SOM_2020_5_15_values = SOM_2020_5_15_values$layer,
    SOM_2023_0_5_values = SOM_2023_0_5_values$SOM_per_2023_d_0_5_QRF_pred_mean,
    SOM_2023_5_15_values = SOM_2023_5_15_values$SOM_per_2023_d_5_15_QRF_pred_mean) %>%
  select(-contains("ID") | Site_ID) # Remove 'ID' columns except for Site_Identification

head(NOBV_Point_Data)
str(NOBV_Point_Data)


# Export the dataframe with the extracted raster values to a CSV file
write.csv(NOBV_Point_Data, "NOBV_Point_Data_Extracted.csv", row.names = FALSE)

# Print a success message to confirm the file has been saved
print("Data has been successfully exported to 'NOBV_Point_Data_Extracted.csv'")

#---------------------------