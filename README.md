# MISO Energy Demand Forecasting

---

## Project Overview

This project analyzes monthly aggregated energy consumption data from the MISO (Midcontinent Independent System Operator) power grid footprint. The main goals are to:

- Identify and characterize seasonal trends in energy demand.
- Evaluate whether there is a long-term growth trend after controlling for seasonality.
- Develop and select an appropriate statistical model to forecast future energy demand.

The analysis involves fitting deterministic seasonal models, assessing residuals for time dependencies, and generating forecasts with confidence intervals. The sinusoidal model was found to best capture the seasonal pattern, with residuals behaving like white noise.

---

## Dataset

- The dataset consists of hourly energy consumption data for the MISO region from 2021 to 2024.
- Hourly data was aggregated into monthly totals to facilitate time series analysis.
- The data shows clear seasonal variation with higher loads during extreme weather months (winter and summer).

---

## Methods

1. **Data Preparation:** Hourly load data was imported, filtered for relevant columns, and aggregated by month.
2. **Exploratory Analysis:** Time series plots revealed strong seasonal patterns.
3. **Model Fitting:**  
   - Seasonal Means Model: Uses historical monthly averages as predictors.  
   - Sinusoidal Model: Fits a harmonic (cosine) function to capture periodicity.  
4. **Model Comparison:** Models were compared using AIC and BIC criteria. The sinusoidal model had better fit statistics.
5. **Residual Diagnostics:**  
   - Residuals were analyzed with histograms and Q-Q plots for normality.  
   - Runs test and Augmented Dickey-Fuller (ADF) test confirmed residuals behave as white noise and are stationary.  
   - ACF and PACF plots showed no significant autocorrelations.  
6. **Forecasting:**  
   - Sinusoidal model with white noise residuals was used to forecast the next 12 months with confidence intervals.

---

## Results

- The sinusoidal model accurately captured the seasonal structure of the MISO load data.
- No evidence of long-term increasing or decreasing trend after controlling for seasonality.
- Residual diagnostics support the model assumptions of stationarity and independence.
- Forecasts suggest stable seasonal patterns continuing into the near future.
- Extreme fluctuations and anomalies were not fully captured, suggesting scope for further model refinement using additional predictors such as weather or economic variables.

---

## Usage

- Required R packages should be installed: `TSA`, `dplyr`, `lubridate`, `tseries`
