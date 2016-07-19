#!/usr/bin/

#library(sm)

cap_title <- function(title_string) {
  s <- strsplit(title_string, " ")[[1]]
    paste(toupper(substring(s, 1,1)), substring(s, 2),
          sep="", collapse=" ")
}

# load forecast data (downloaded from pro box office), and add column info
load_forecast_by_date <- function(date_string) {

  # generate relative path to forecast data, then read from csv
  filename = paste('data/', date_string, '/forecast-pbo-', date_string,
                         '.csv', sep='')
  forecast = read.csv(filename, header=FALSE, stringsAsFactors=FALSE)

  # set column names for the data 
  colnames(forecast) <- c("title", "distributor", "weekend", "total")

  # capitalize all words in movie title
  forecast$title = sapply(forecast$title, cap_title)

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
  actual = read.csv(filename, header=FALSE, stringsAsFactors=FALSE)

  # set column names
  colnames(actual) <- c("number", "title", "weekend", "wkd-change", "locations",
                        "loc-change", "average", "total", "weeks",
                        "distributor")

  # capitalize all words in movie title
  actual$title = sapply(actual$title, cap_title)

  # remove non-numercial characters from currency columns
  actual$weekend <- as.numeric(gsub("\\,","", sub("\\$","", actual$weekend)))
  actual$total <- as.numeric(gsub("\\,","", sub("\\$","", actual$total)))
  actual$average <- as.numeric(gsub("\\,","", sub("\\$","", actual$average)))

  # divide box office numbers by millions
  actual$weekend = actual$weekend / 1000000
  actual$total = actual$total / 1000000

  # set week to factor
  actual$weeks = factor(actual$weeks)

  # adjust change columns to decimals or missing
   
  return(actual)
}

merge_data <- function(forecast, actual) {
  merged_data = merge(forecast, actual, by="title")
  return(merged_data)
}

forecast_and_actual_by_date <- function(date_full) {
  date_string = gsub("-", "", date_full)
  merged = merge_data(load_forecast_by_date(date_string),
                      load_actual_by_date(date_string))
  merged$date <- as.Date(date_full)
  merged_collapsed = merged[,c("date", "title", "weeks", "weekend.x", "weekend.y")]
  merged_collapsed$diff = (merged_collapsed$weekend.y - 
                           merged_collapsed$weekend.x) / 
                           merged_collapsed$weekend.y
  return(merged_collapsed)
}

dates = c('2016-05-20', '2016-05-27', '2016-06-03', '2016-06-10', '2016-06-17')
f_and_a = lapply(dates, forecast_and_actual_by_date)
merged_combo = do.call("rbind", f_and_a)

