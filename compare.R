# load forecast data from pro box office
forecast = read.csv("forecast-pbo-20160512.csv", header = FALSE)

# drop some zeroes off some of the colums
forecast$V3 = forecast$V3 / 100000
forecast$V4 = forecast$V4 / 100000

# import the pricing data
pricing = read.csv("pricing-fml-20160512.csv", header = FALSE)

# merge the data tables
dat3_raw = merge(x = forecast, y=pricing, by="V1")

# generate linear regression line
line = lm(dat3_raw$V3 ~ dat3_raw$V2.y)

# add residuals and sort
dat3_raw$res = residuals(line)
dat3 <- dat3_raw[order(dat3_raw$res),]


line_plot <- function() {
  plot(x=dat3$V2.y, y=dat3$V3, ylab="forecast", xlab="pricing")
  text(dat3$V2.y, dat3$V3, dat3$V1, cex=0.6)
  abline(line)
}

bar_plot <- function() {
  par(las=2)
  par(mar=c(5,8,4,2))
  barplot(height=dat3$res, horiz=TRUE, names.arg=dat3$V1, cex.names=0.5)
}
