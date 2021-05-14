#Kayla Blincow
#5/10/2021

#The purpose of this script is create a map of the sampling locations for GSB
#fin clips

#clear my workspace
rm(list = ls())

#load the packages
library(ggplot2) #if you don't know ggplot yet, holla, and I will give more details
library(dplyr) #tidyverse data wrangling package
library(ggsn) #add north symbols and scale bars
library(mapdata) #package full of basemaps

#set working directory (**note** I recommend working in projects so you don't 
#have to deal with this all the time)
setwd("C:/Users/kmbli/OneDrive - UC San Diego/PhDzNuts/Giant Sea Bass/Isotopes/IsotopesAnalysis/")

#load the data
d <- read.csv("FinalGSBBulk.csv", header = T)

#take a look at the data
head(d)

#need to collapse data to unique lat/long data
d2 <- select(d, lat, long, sample_loc) %>% 
  unique()

head(d2)

#there are a few spots from the broader area, but not exactly the same lats/longs
#remove extra points
d2 <- d2[-c(2, 10, 14:16),] #manually remove

#you could also use something like first() to accomplish the same goal

head(d2)

#I think I might want to scale my points by the number of samples there
#breakdown lat/long and sum
d3 <- d %>% 
  group_by(sample_loc) %>% 
  summarize(n()) %>% 
  left_join(d2)

names(d3) <- c("sample_loc", "tot", "lat", "long")

#pull our base map
world <- map_data("mapdata::worldHires")

head(world)

#let's try making a map!
#Start by throwing on our basemap
ggplot() + 
  geom_polygon(data = world, aes(x = long, y = lat, group = group))

#obvi this is the whole world and we don't actually need the whole world..
#let's try to limit the extent of our x and y axes to tunnel in on the location 
#we actually want
ggplot() + 
  geom_polygon(data = world, aes(long, lat, group = group)) +
  scale_x_continuous(limits = c(-121, -105)) +
  scale_y_continuous(limits = c(25,35)
  )

#welll... that's definitely not what we want...
#this is a common problem when working with geom_polygon
#I got around it using coord_cartesian to set the coordinates of the map
#*NOTE: this will manually set the coordinate space of your map, and won't
#dynamically scale as you adjust your viewing pane
ggplot() + 
  geom_polygon(data = world, aes(long, lat, group = group)) +
  coord_cartesian(xlim = c(-121, -105), ylim = c(25, 35)) 

#phew that's better..

#let's add some points!
ggplot() + 
  geom_polygon(data = world, aes(long, lat, group = group)) +
  coord_cartesian(xlim = c(-121, -105), ylim = c(25, 35))  +
  geom_point(data = d3, aes(x = long, y = lat)) 


#those are tiny and hard to see...
#let's change the shape, the color of the land, and scale the points by the number
#of samples
ggplot() + 
  geom_polygon(data = world, aes(long, lat, group = group),
               fill = "gray60", color = "gray30") +
  coord_cartesian(xlim = c(-121, -105), ylim = c(25, 35))  +
  geom_point(data = d3, aes(x = long, y = lat, size = tot), shape = 17) 

#I don't love scaling the points by the number of samples, because some sites
#have really small sample sizes, so I'll just set them all the same size
#also going to make the water white and outline the plot
ggplot() + 
  geom_polygon(data = world, aes(long, lat, group = group),
               fill = "gray60", color = "gray30") +
  coord_cartesian(xlim = c(-121, -105), ylim = c(25, 35))  +
  geom_point(data = d3, aes(x = long, y = lat), size = 4, shape = 17) +
  labs(x = "Longitude", y = "Latitude")+
  theme_classic()+
  theme(text = element_text(size=20),
        panel.border = element_rect(colour = "black", fill=NA, size=2)) 

#we are getting there!! now all we need to do now is add the scale bar and north arrow!
?scalebar
?north

#pick a north symbol
northSymbols()

#took a fair amount of finagling to get these where I wanted them, and reasonable
#sizes but I'll show you the end product code (happy to play around with it if
#anyone wants)
ggplot() + 
  geom_polygon(data = world, aes(long, lat, group = group),
               fill = "gray60", color = "gray30") +
  coord_cartesian(xlim = c(-121, -105), ylim = c(25, 35))  +
  geom_point(data = d3, aes(x = long, y = lat), size = 4, shape = 17) +
  labs(x = "Longitude", y = "Latitude")+
  theme_classic()+
  theme(text = element_text(size=20),
        panel.border = element_rect(colour = "black", fill=NA, size=2)) +
  north(symbol = 16, location = "topright", scale = 0.2, 
        x.min = -121, x.max = -105, y.min = 25, y.max = 35) +
  scalebar(dist = 250, dist_unit = "km", x.min = -121, 
           x.max = -105, y.min = 25, y.max = 35, location = "bottomleft",
           transform = TRUE, model = "WGS84", st.bottom = FALSE,
           st.dist = 0.03, st.size = 4) 
  

#now that's it's gorgeous I'll assign it to an object and export as a png
map <- ggplot() + 
  geom_polygon(data = world, aes(long, lat, group = group),
               fill = "gray60", color = "gray30") +
  geom_point(data = d3, aes(x = long, y = lat), size = 4, shape = 17) +
  coord_cartesian(xlim = c(-121, -105), ylim = c(25, 35)) +
  north(symbol = 16, location = "topright", scale = 0.2, 
        x.min = -121, x.max = -105, y.min = 25, y.max = 35) +
  scalebar(dist = 250, dist_unit = "km", x.min = -121, 
           x.max = -105, y.min = 25, y.max = 35, location = "bottomleft",
           transform = TRUE, model = "WGS84", st.bottom = FALSE,
           st.dist = 0.03, st.size = 4) +
  labs(x = "Longitude", y = "Latitude")+
  theme_classic()+
  theme(text = element_text(size=20),
        panel.border = element_rect(colour = "black", fill=NA, size=2)) 


png(filename="MSFigures/Iso_SampleMap_RUsers.png", 
    units="in", 
    width=7, 
    height=6, 
    pointsize=8, 
    res=400)

map

dev.off()
