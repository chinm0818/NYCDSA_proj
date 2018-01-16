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
print(sum(is.na(oil$Latitude))) #let's get an idea of of how many values are not on map
# about 40% of entrys have no lat/long
oil_map = ggplot(data = oil, aes(x = Longitude, y = Latitude)) + geom_point()
counties = readOGR(path.expand("~/NYCDSA/Projects/Borough Boundaries/nycbb.shp"), layer = "nycbb")
# required path expand to get this to work
NY_county = subset(counties, region == "new york")
NYC_county = filter(NY_county, subregion %in% c('new york', 'kings', 'queens', 'richmond', 'bronx'))
#nyc_base = ggplot(data = NYC_county, aes(x = long, y = lat)) + geom_polygon() # not very useful. fairly low res in accurate map
nyc_base = ggplot() = geom_polygon(data = counties, aes(x=long, y=lat, group = group))

# did a search for borough boundary shp files
# https://data.cityofnewyork.us/City-Government/Borough-Boundaries/tqmj-j8zm/data
