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


