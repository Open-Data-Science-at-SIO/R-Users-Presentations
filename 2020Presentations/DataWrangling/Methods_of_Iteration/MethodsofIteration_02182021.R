# R-users 2/18/2021
# Jordan DiNardo
# Methods of Iteration (for loops, apply functions, and so much more in purr) 


#-------------------------------------------------------------------------------
#For Loops 

#General Syntax

for (val in sequence)
{
  statement
}

#Example 1

for (i in letters[1:5]){
  print(i)
}

#Example 2

nsteps <- 200
x <- numeric(nsteps + 1)
x[1] <- 0 # start at 0
#create step function
step <- function(x, p=0.5){
  x + ifelse(runif(1) < p, -1,1)
}
#perform random walk
for (i in 2:nsteps){
  x[i+1] <- step(x[i])
}
plot(x, type="l") #plot random walk

#-------------------------------------------------------------------------------
#Apply Functions

#apply
mat <- matrix(1:10,ncol=2,nrow=5)
apply(mat,1,mean) #calculate row means
apply(mat,2,mean) #calculate col means

#lapply
vec1 <- c(5,17,9,12)

#input list; output list
lapply(vec1,function(x){x+1})

vec2 <- c(101,2,67,40)
vec3 <- c(33,5,98,6)

vec_list <- list(vec1, vec2, vec3)

#input list; output list
lapply(vec_list,function(x){x+1})
lapply(vec_list,mean)

#sapply
#input list; output vector (simplest form)
sapply(vec_list,mean)

#vapply (indicate your desrired output)
vapply(vec_list,mean,numeric(1))

#mapply
mapply(rep, 1:9, 9:1)


#Comparison of for loops vs apply functions

for(i in 1:length(vec_list)){
  
  print(mean(vec_list[[i]]))
}

#how long does that take?
system.time(for(i in 1:length(vec_list)){
  
  print(mean(vec_list[[i]]))
})


#Apply Functions
lapply(vec_list,mean)

#how long does that take? Is the apply funtions that much faster?
system.time(lapply(vec_list,mean))

#-------------------------------------------------------------------------------

# Let's learn to purr!! 
library(tidyverse)
#library(purrr)

#----------------------
#Map functions-basics

#create function that adds ten to each value
addTen <- function(x) {
  return(x + 10)
}

#apply 'addTen' fxn to vector
map( .x=c(1, 4, 7), .f = addTen)

#apply 'addTen' fxn to list of vectors
map(list(1, 4, 7), addTen)

#apply 'addTen' fxn to a df
map(data.frame(a = 1, b = 4, c = 7), addTen)
#note: no matter the input the output is always a list

#use specific map function to return the corresponding output 
map_dbl(c(1, 4, 7), addTen) #returns a vector of numeric
map_chr(c(1, 4, 7), addTen) #returns a vector of characters
map_df(c(1, 4, 7), function(x) { #return a df
  return(data.frame(old_number = x, 
                    new_number = addTen(x)))
})

#----------------------
#Map functions-gapminder data

# Download data
gapminder_orig <- read.csv("https://urldefense.com/v3/__https://raw.githubusercontent.com/swcarpentry/r-novice-gapminder/gh-pages/_episodes_rmd/data/gapminder-FiveYearData.csv__;!!Mih3wA!SWM8Q4yssfDkn54_z6aJWqvQb_8RxHmGy82H2O65xTHqUS2ew6KvlLDeoVSqLEeu$ ")
# define a copy of the original dataset that we will clean and play with 
gapminder <- gapminder_orig
head(gapminder)


# apply the class() function to each column
gapminder %>% map_chr(class)

# apply the n_distinct() function to each column
gapminder %>% map_dbl(n_distinct)

# apply a few different summary functions to each column in a data frame
gapminder %>% map_df(~(data.frame(n_distinct = n_distinct(.x),
                                  class = class(.x))))

# use map functions to create a list of plots that compare life expectancy and GDP 
  # per capita for each continent/year combination

# obtain  all distinct combinations of continents and years
continent_year <- gapminder %>% distinct(continent, year)
continent_year

# extract the continent and year pairs as separate vectors
continents <- continent_year %>% 
  pull(continent) %>% 
  as.character()
years <- continent_year %>% 
  pull(year)

#use map2 to plot  
plot_list <- map2(.x = continents, 
                  .y = years, 
                  .f = ~{
                    gapminder %>% 
                      filter(continent == .x,
                             year == .y) %>%
                      ggplot() +
                      geom_point(aes(x = gdpPercap, y = lifeExp)) +
                      ggtitle(glue::glue(.x, " ", .y))
                  })

plot_list[[1]]
plot_list[[2]]
plot_list[[13]]
#----------------------
# List columns and nested data 

#create a nested data frame grouped by continent 
gapminder_nested <- gapminder %>% 
  group_by(continent) %>% 
  nest()
gapminder_nested

# view first element of nested data frame
gapminder_nested$data[[1]]

#This allows you to use dplyr manipulations on more complex objects stored in lists!!

# calculate average life expectancy by continent using map_dbl fxn
gapminder_nested %>% 
  mutate(avg_lifeExp = map_dbl(data, ~{mean(.x$lifeExp)}))
# yeah yeah it's similar to using the group_by and summarise fxns


# fit a model separately for each continent
gapminder_nested <- gapminder_nested %>% 
  mutate(lm_obj = map(data, ~lm(lifeExp ~ pop + gdpPercap + year, data = .x)))
gapminder_nested

gapminder_nested %>% pluck("lm_obj", 1)

# predict the response for each continent
gapminder_nested <- gapminder_nested %>% 
  mutate(pred = map2(lm_obj, data, function(.lm, .data) predict(.lm, .data)))
gapminder_nested

# calculate the correlation between observed and predicted response for each continent
gapminder_nested <- gapminder_nested %>% 
  mutate(cor = map2_dbl(pred, data, function(.pred, .data) cor(.pred, .data$lifeExp)))
gapminder_nested

# Did I wow ya?!

#Resources
# https://urldefense.com/v3/__https://github.com/rstudio/cheatsheets/blob/master/purrr.pdf__;!!Mih3wA!SWM8Q4yssfDkn54_z6aJWqvQb_8RxHmGy82H2O65xTHqUS2ew6KvlLDeoaZBKtig$ 
# https://urldefense.com/v3/__https://emoriebeck.github.io/R-tutorials/purrr/__;!!Mih3wA!SWM8Q4yssfDkn54_z6aJWqvQb_8RxHmGy82H2O65xTHqUS2ew6KvlLDeocerYr7s$ 
# https://urldefense.com/v3/__http://www.rebeccabarter.com/blog/2019-08-19_purrr/*list-columns-and-nested-data-frames__;Iw!!Mih3wA!SWM8Q4yssfDkn54_z6aJWqvQb_8RxHmGy82H2O65xTHqUS2ew6KvlLDeoX9wzZRd$ 
# https://urldefense.com/v3/__https://nicercode.github.io/guides/repeating-things/__;!!Mih3wA!SWM8Q4yssfDkn54_z6aJWqvQb_8RxHmGy82H2O65xTHqUS2ew6KvlLDeoRxqBrV6$ 
