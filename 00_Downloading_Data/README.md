## Google Earth Engine (GEE) scripts used to download the remotely sensed data (RSD)

| Script Name | Description | Link |
|------------|------------|-------------|
| 00_01_Download_S1_VSM  | Compute and download Soil Moisture Content (SMC) for specific sites using Sentinel-1 GRD data. | [View Script](https://code.earthengine.google.com/05d1910b3fd5bb0be1c8b46a275bb61c) |
| 00_02_Download_S1_Backscatter  | Compute and download SAR backscatter data for specific sites using Sentinel-1 and Sentinel-1 Standard Deviation data. | [View Script](https://code.earthengine.google.com/27d613439513d63ba45560653960f61a?noload=true) |
| 00_03_ Download_L8_and_9_LST | Download land surface temperature (LST) using Landsat 8 and 9 data | [View Script](https://code.earthengine.google.com/8deef0200fe7de6a513daa45a73ede8b?noload=true) |
| 00_04_Download_MODIS_LAI | Download Leaf Area Index (LAI) data derived from MODIS | [View Script](https://code.earthengine.google.com/bfa95049b25c3e84ece7b847678f9052?noload=true) |
| 00_05_Download_S2_Indices | Compute and download spectral indices derived from Sentinel-2 | [View Script](https://code.earthengine.google.com/a93a1f31af11bfb100ea48a066514bf5?noload=true) |


 GEE asset of the area of interest (NOBV locations) used in the scripts: 
   https://code.earthengine.google.com/?asset=projects/ee-robthesis/assets/NOBV_EC_50m_SQ_buff_4326 