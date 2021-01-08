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


#look at the 11-14th values


#do this with a dataframe

#look at the 7th row


#add 1 to value column



#subtract 1 from value column


#Creating a simple for loop
#do the same as above--add 1 to the value column--using a for loop


#what if we want to add one to all the values using a for loop??


#how about using vectorization? subtract 1 from all values in the df



#apply functions: subtract 1 from the value column


#calculate summary statistics for all of our columns




