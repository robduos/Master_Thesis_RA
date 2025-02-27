
1. Download S1 VSM : https://code.earthengine.google.com/05d1910b3fd5bb0be1c8b46a275bb61c  
2. Download S1-Backscatter coefficient (σ°) : https://code.earthengine.google.com/ae47c6e5ac208532a393b6e3e31d0532?noload=true 
3. Download L8 & 9 LST : https://code.earthengine.google.com/8deef0200fe7de6a513daa45a73ede8b?noload=true 
4. Download MODIS LAI : https://code.earthengine.google.com/bfa95049b25c3e84ece7b847678f9052?noload=true 
5. Download S2 Indices : https://code.earthengine.google.com/a93a1f31af11bfb100ea48a066514bf5?noload=true 

   GEE asset of the area of interest (NOBV locations) used in the scripts: 
   https://code.earthengine.google.com/?asset=projects/ee-robthesis/assets/NOBV_EC_50m_SQ_buff_4326 



   ## Google Earth Engine scripts used to download the relevant remotely sensed data

| Script Name | Description | Link |
|------------|------------|-------------|
| 00_01_Download_S1_VSM  | Compute and download Volumetric Soil Moisture for specific sites using Sentinel 1 data. | [View Script](https://code.earthengine.google.com/05d1910b3fd5bb0be1c8b46a275bb61c) |
| 00_02_Download_S1_Backscatter  | Compute and download SAR backscatter data for specific sites using Sentinel 1 data. | [View Script](https://code.earthengine.google.com/ae47c6e5ac208532a393b6e3e31d0532?noload=true) |
| 00_03_ Download_L8_and_9_LST | Download land surface temperature (LST) using Landsat 8 and 9 data | [View Script](https://code.earthengine.google.com/8deef0200fe7de6a513daa45a73ede8b?noload=true) |
| 00_04_Download_MODIS_LAI | Download Leaf Area Index (LAI) data derived from MODIS | [View Script](https://code.earthengine.google.com/bfa95049b25c3e84ece7b847678f9052?noload=true) |
| 00_05_Download_S2_Indices | Compute and download spectral indices derived from Sentinel-2 | [View Script](https://code.earthengine.google.com/a93a1f31af11bfb100ea48a066514bf5?noload=true) |