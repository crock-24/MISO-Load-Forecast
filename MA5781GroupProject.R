library(TSA)
library(dplyr)
library(lubridate)
library(tseries)

# Set the working directory to where the data is located
setwd("/Users/crorick/Documents/MS\ Applied\ Stats\ Fall\ 2023/MA5781/group_project")

#read the data in
miso.2021 <- read.csv('miso_load_act_hr_2021.csv', skip = 3)
miso.2022 <- read.csv('miso_load_act_hr_2022.csv', skip = 3)
miso.2023 <- read.csv('miso_load_act_hr_2023.csv', skip = 3)
miso.2024 <- read.csv('miso_load_act_hr_2024.csv', skip = 3)

#choose only columns of interest
miso.2021 <- data.frame(miso.2021$MISO.Total.Actual.Load..MW., miso.2021$Local.Timestamp.Eastern.Standard.Time..Interval.Beginning., miso.2021$Local.Timestamp.Eastern.Standard.Time..Interval.Ending.)
miso.2022 <- data.frame(miso.2022$MISO.Total.Actual.Load..MW., miso.2022$Local.Timestamp.Eastern.Standard.Time..Interval.Beginning., miso.2022$Local.Timestamp.Eastern.Standard.Time..Interval.Ending.)
miso.2023 <- data.frame(miso.2023$MISO.Total.Actual.Load..MW., miso.2023$Local.Timestamp.Eastern.Standard.Time..Interval.Beginning., miso.2023$Local.Timestamp.Eastern.Standard.Time..Interval.Ending.)
miso.2024 <- data.frame(miso.2024$MISO.Total.Actual.Load..MW., miso.2024$Local.Timestamp.Eastern.Standard.Time..Interval.Beginning., miso.2024$Local.Timestamp.Eastern.Standard.Time..Interval.Ending.)

#rename columns of interest
colnames(miso.2021) <- c('actual_load', 'end_time')
colnames(miso.2022) <- c('actual_load', 'end_time')
colnames(miso.2023) <- c('actual_load', 'end_time')
colnames(miso.2024) <- c('actual_load', 'end_time')

#concatenate the data
MISO <- bind_rows(miso.2021, miso.2022, miso.2023, miso.2024)

#convert to time series data for manipulation
MISO$end_time <- as.Date(MISO$end_time)

#converting hourly data to monthly
MISO$end_time <- floor_date(MISO$end_time, 'month')

#sum monthly data
MISO <- MISO %>%
    group_by(end_time) %>%
    summarize(monthly_sum = sum(actual_load))

#convert data into a time series object for ease of analysis
MISO <- ts(MISO$monthly_sum, frequency = 12, start = c(2021, 2))

#plot the data
plot(MISO, type = 'l', xlab = 'Time', ylab = 'Load (MW)', main = 'MISO Monthly Load Data (2021-2025)')
points(y = MISO, x = time(MISO), pch=as.vector(season(MISO)))

#seasonal means model
month <- season(MISO)
seasonal.MISO.lm <- lm(MISO ~ month + time(MISO))
AIC(seasonal.MISO.lm)
BIC(seasonal.MISO.lm)

#Use least squares to fit a cosine trend with fundamental frequency 1/12 to the
#percentage change series. Interpret the regression output.
har <- harmonic(MISO, m=1)
MISO.har.lm <- lm(MISO ~ har)
AIC(MISO.har.lm)
BIC(MISO.har.lm)
resid.har <- rstandard(MISO.har.lm)

#Standardized residuals of harmonics model plot
plot(resid.har, ylab='Standardized Residuals', main = 'Sinusoidal Model')
abline(h=0)

#Dickey Fuller Test
adf.test(resid.har, k=0)

#runs test
runs(resid.har)

#Autocorrelation Function plot
acf(resid.har, main = "ACF of sinusoidal model")

#Partial Autocorrelation Function plot
pacf(resid.har, main = "PACF of sinusoidal model")

#histogram of residuals
hist(resid.har, xlab = 'Standardized residuals', main = 'Sinusoidal Model')

#qqplot of residuals
qqnorm(resid.har)
qqline(resid.har)

#plot the seasonal means and sinusoidal with the actual
matplot(cbind(predict(MISO.har.lm), predict(seasonal.MISO.lm), MISO), 
        type = "l", lty = 1, col = c("orange", "purple", "black"), xlab = "time", 
        ylab = "load (MW)", main = "Model Comparison")
legend("bottomleft", legend = c("Sinusoidal", "Seasonal Means", "Actual"), 
       col = c("orange", "purple", "black"), lty = 1)

# WN model to forecast the next 12 values of this series.
future.time <- ts(start = c(2024,12), end = c(2028,9), frequency = 12)
future.har <- as.data.frame(harmonic(future.time, m=1))
predictions <- predict(MISO.har.lm, newdata = future.har, type = 'response')
se <- sqrt(var(MISO))

#Plot the series, the forecasts, and 95% forecast limits, and 
#interpret the results.
WN.train.pred <- c(MISO, predictions[1:12])
uci <- predictions[1:12] + 2*se*rep(1, times = 12)
lci <- predictions[1:12] - 2*se*rep(1, times = 12)
WN.train.upper.ci <- c(MISO, uci)
WN.train.lower.ci <- c(MISO, lci)
matplot(cbind(WN.train.upper.ci, WN.train.lower.ci, WN.train.pred), 
        type = "l", lty = 1, col = c("red", "red", "blue"), xlab = "time", 
        ylab = "load (MW)", main = "WN model load forecast")
legend("bottomleft", legend = c("upper CI", "lower CI", "prediction"), 
       col = c("red", "red", "blue"), lty = 1)
