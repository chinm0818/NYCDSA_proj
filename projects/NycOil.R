library(ggplot2)
library(maps)
library(dplyr)
library(mapdata)
library(rgdal)
#energy = read.csv('Energy_use.csv')
oil = read.csv('oil_boilers.csv')

#we'll look at data on oil_boilers in NYC
#let's start by inspecting data
print(dim(oil))
print(sum(is.na(oil$Latitude)))
print(colnames(oil))
#let's get an idea of of how many values are not on map
# about 40% of entrys have no lat/long. 
# let's get a better idea of whats missing and what we can extrapolate

#first. Which boroughs is this data missing 
# compare number of missing data to how much is there per borough
na_count = oil %>%
  group_by(., Borough) %>%
  summarise(., count_na = sum(is.na(Latitude)), counts = n()) %>%
  mutate(., perc_missing = count_na/counts * 100)

#turns out the most missing data is from manhattan
#but there are so many data points there it might not matter
# let's explore what's left when we remove data w/o location
oil2 = oil %>%
  filter(., !is.na(Latitude))


#What questions do we want to answer with this data set?
#1. Where are these boilers located
#2. When where they installed
#3. How much fuel do they consume?
#3a. How much money is fuel is consumed?
#4. When are they due to being replaced? 
#5. 

#messing with plotting spatial data

counties = readOGR("nycbb.shp", layer = "nycbb")

nyc_base = ggplot() + geom_polygon(data = counties, aes(x=long, y=lat, group = group)) 
+ theme(panel.background = element_rect(fill = NA))


combined_map = ggplot() + 
  geom_polygon(data = counties, aes(x=long, y=lat, group = group)) +
  geom_point(data = oil, aes(x = Longitude, y = Latitude, color = 'red')) 
# to split up code acros multiple rows, leave operator at the end of break
# did a search for borough boundary shp files
# https://data.cityofnewyork.us/City-Government/Borough-Boundaries/tqmj-j8zm/data
