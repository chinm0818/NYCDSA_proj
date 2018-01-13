library(ggplot2)
library(maps)
#energy = read.csv('Energy_use.csv')
oil = read.csv('oil_boilers.csv')

#we'll look at data on oil_boilers in NYC
#let's start by inspecting data
sum(is.na(oil$Latitude)) #let's get an idea of 