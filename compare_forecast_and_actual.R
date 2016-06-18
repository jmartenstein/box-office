#!/usr/bin/

# load forecast data (downloaded from pro box office), and add column info
load_forecast_by_date <- function(date_string) {

  # generate relative path to forecast data, then read from csv
  filename = paste('data/', date_string, '/forecast-pbo-', date_string,
                         '.csv', sep='')
  forecast = read.csv(filename)

  # set column names for the data 
  colnames(forecast) <- c("title", "distributor", "weekend", "total")

  # divide the box office data by millions
  forecast$weekend = forecast$weekend / 1000000
  forecast$total = forecast$total / 1000000

  return(forecast)
}

# load actual data (also from pro box office)
load_actual_by_date <- function(date_string) {

  # generate relative path to actual data and read from csv
  filename = paste('data/', date_string, '/actual-pbo-', date_string,
                         '.csv', sep='')
  actual = read.csv(filename)

  # set column names
  colnames(actual) <- c("number", "title", "weekend", "wkd-change", "locations",
                        "loc-change", "average", "total", "weeks",
                        "distributor")

  # remove non-numercial characters from currency columns
  actual$weekend <- as.numeric(gsub("\\,","", sub("\\$","", actual$weekend)))
  actual$total <- as.numeric(gsub("\\,","", sub("\\$","", actual$total)))
  actual$average <- as.numeric(gsub("\\,","", sub("\\$","", actual$average)))

  # divide box office numbers by millions
  actual$weekend = actual$weekend / 1000000
  actual$total = actual$total / 1000000

  # adjust change columns to decimals or missing
   
  return(actual)
}

merge_data <- function(forecast, actual) {
  merged_data = merge(forecast, actual, by="title")
  return(merged_data)
}
