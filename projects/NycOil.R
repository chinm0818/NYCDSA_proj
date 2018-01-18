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
clean_oil = oil %>%
  filter(., !is.na(Latitude)) %>%
  rename(Retirement = Estimated.retirement.date.of.boiler..assuming.35.year.average.useful.life. )



#What questions do we want to answer with this data set?
#1. Where are these boilers located
#2. When where they installed
#3. How much fuel do they consume?
#3a. How much money is fuel is consumed?
#4. When are they due to being replaced? 

## Main Thesis: NYC has dates set to phase out thousands of boilers in nyc between 2010 and 2040.
## Each burns hundreds of thousands of oil worth of btus a year. 
## knowing when and where these units are being phased out would be useful in planning efforts to switch to gas units 
## no 4 and no 6 are dirty burining oils. no 6 was to be phased out 2015
## all burners are mandated to be on no 2 or nat gas by 2030
## source https://www.nytimes.com/2014/04/07/nyregion/cost-among-hurdles-slowing-new-yorks-plan-to-phase-out-dirty-heating-oil.html


#messing with plotting spatial data

counties = readOGR("nycbb.shp", layer = "nycbb")

nyc_base = ggplot() + geom_polygon(data = counties, aes(x=long, y=lat, group = group)) 




# to split up code acros multiple rows, leave operator at the end of break
# did a search for borough boundary shp files
# https://data.cityofnewyork.us/City-Government/Borough-Boundaries/tqmj-j8zm/data


# let's work on filtering data appropriately
year1 = 2039
year2 = 2040
filtered_oil = clean_oil %>%
  filter(., Retirement >= year1 & Retirement <= year2) %>%
  filter(., Natural.Gas.Utility..Con.Edison.or.National.Grid %in% c('National Grid'))

combined_map = ggplot() + 
  geom_polygon(data = counties, aes(x=long, y=lat, group = group)) +
  geom_point(data = filtered_oil, aes(x = Longitude, y = Latitude, color = 'red')) 


retire_count = filtered_oil %>%
  group_by(., Borough) %>%
  summarize(., count = n())

count_plot = ggplot(data=filtered_oil, aes(x = Borough))
