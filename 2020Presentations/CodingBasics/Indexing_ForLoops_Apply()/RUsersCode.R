#R Users Indexing, For Loops, and Apply Functions
#Kayla Blincow


#clear workspace
rm(list = ls())

#load packages
library(tidyverse)


#Basic indexing examples
#create some dummy data
vec <- sample(1:1000, 25)
#look at it
vec

#look at the 5th value
vec[5]
#look at the 11-14th values
vec[11:14]

#do this with a dataframe
df <- data.frame(1, 1:10, sample(1:1000, 10))
names(df) <- c("group", "site", "value")

#look at the 7th row
df[7,]

#add 1 to value column
df[,3] <- df[,3] + 1 #(vectorization amirite???)

#subtract 1 from value column
df$value <- df$value - 1

#Creating a simple for loop
#do the same as above--add 1 to the value column--using a for loop
for(i in 1:nrow(df)){
  df$value[i] <- df$value[i] + 1
}

#what if we want to add one to all the values using a for loop??
for(i in 1:nrow(df)){
  for(ii in 1:ncol(df)){
    df[i,ii] <- df[i,ii] + 1
  }
}

#how about using vectorization? subtract 1 from all values in the df
df <- df - 1

#apply functions: subtract 1 from the value column
newv <- sapply(df$value, function (x) x - 1)
#calculate summary statistics for all of our columns
sumstats <- apply(df, 2, function(x) c(mean(x), sd(x), median(x)))



#Real Life Example

#load data
d1 <- read.csv("DataExports/2018_all.csv", header = T)
names(d1) <- c("Direction", "Reporter", "Partner", "Product", 
              "Product_Description", "HS2", "HS4", "HS6", "Currency", "Unit",
              "Value", "Quantity", "Trade_Period", "Trade_Year", "Trade_Month",
              "Trade_Quarter", "Trade_Half")

#DON'T RUN THIS, IT WILL TAKE FOREVER!!!
#for loop to create a column based on values from another column
for(i in 1:nrow(d1)){
  if(d1$Unit[i] == "LB"){
    d1$QuantT[i] <- d1$Quantity[i]*0.000453592
  } else if(d1$Unit[i] == "KG" | d1$Unit[i] == "KN"){
    d1$QuantT[i] <- d1$Quantity[i]*0.001
  } else if(d1$Unit[i] == "T"){
    d1$QuantT[i] <- d1$Quantity[i] 
  }
}

#takes a long time, especially because I have to iterate over millions of rows
#BUT we can use R's vectorization to speed up the process
d1$QuantT <- NA
d1[d1$Unit == "LB",]$QuantT <- d1[d1$Unit == "LB",]$Quantity*0.000453592
d1[d1$Unit == "KG" | d1$Unit == "KN",]$QuantT <- 
  d1[d1$Unit == "KG" | d1$Unit == "KN",]$Quantity*0.001
d1[d1$Unit == "T", ]$QuantT <- d1[d1$Unit == "T",]$Quantity

#how about apply functions?
#using mapply() to create a new variable
#I want to know what the Real Value of each product is (i.e. Value/QuantT)
RV <- mapply(function(x, y) x/y, d1$Value, d1$QuantT)

#note we can just do this directly as well...
RV2 <- d1$Value/d1$QuantT
