## Table of scripts used to perform non-linear regression  

| Script Name | Description | Link |
|------------|------------|-------------|
|  03_01_NEE_SWC_Model_V1| This script loads, cleans, and pre-processes the datset to prepare it for modeling. It defines and fits a 5-parameter non-linear model to predict Nighttime Ecosystem Exchange (NEE) of CO2 based on Gross Primary Production (GPP), air temperature (ATMP), soil moisture content (Planet_SMC), and soil temperature (STMP). The script uses multiple initial guesses and parallel processing (`joblib`) for robust parameter estimation via non-linear least squares (`scipy.optimize.curve_fit`). Finally, it evaluates the model's performance using standard regression metrics (R², MSE, RMSE, MAE, Bias, ubRMSE) and visualizes the observed vs. predicted NEE, residuals, and the model's predicted response against Planet_SMC. | [View Script]() |


