#
# Shiny app for NYC_oil project (serverside)
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(rgdal)
library(googleVis)
library(leaflet)

# Establishing data points and map spatial data

counties = readOGR("nycbb.shp", layer = "nycbb") #nyc boroughs map
oil2 = read.csv('clean_oil.csv') #load in data
# nyc_base = ggplot() + geom_polygon(data = counties, aes(x=long, y=lat, group = group)) 



shinyServer(function(input, output) {
  
#let's try to set up our reactive elements:
  
  
  gas_select = reactive({
    switch (input$gas,
            "Con Edison" = "Con Edison",
            "National Grid" = "National Grid",
            "All" = c("Con Edison", "National Grid")
    )
  })
  
  boro_select = reactive({
    switch(input$boro,
           "All" = c(1, 2, 3, 4, 5),
           "Manhattan" = 1,
           "Bronx" = 2,
           "Brooklyn" = 3,
           "Queens" = 4,
           "Staten Island" = 5)
  })
  
  map_select = reactive({
    switch(input$boro,
           "All" = c(1, 2, 3, 4, 5),
           "Manhattan" = 2,
           "Bronx" = 5,
           "Brooklyn" = 3,
           "Queens" = 4,
           "Staten Island" = 1)
  }) 


    
  filtered_oil2 = reactive({ 
    oil2 %>%
      filter(., Borough %in% boro_select()) %>%
      filter(., Retirement >= input$year[1] & Retirement <= input$year[2]) %>%
      filter(., Natural.Gas.Utility..Con.Edison.or.National.Grid %in% gas_select())
    
  })
  
 
  
  
    
    
 #df for googlevis 
  
  
 # leaflet map with geo and data layers 
  output$map <- renderLeaflet({
    
    leaflet(oil2) %>%
      addTiles(urlTemplate = 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_nolabels/{z}/{x}/{y}.png') %>%
      addCircles(color = 'red')%>%
      addPolygons(data = counties)
    #%>%#borough shape data from NYC open data
      #setView(lat = 40.69, lng = -73.8, zoom = 11) don't know it turns off auto zoom
    
  })
  
  # putting in leaflet proxy to control map (faster?)
  
  observe({
    leafletProxy('map', data = filtered_oil2()) %>%
      clearShapes() %>%
      addCircles(color = 'red') %>%
      addPolygons(data = counties[map_select(),])
  })
  
  output$count_data = renderGvis({
    #ggplot(data = filtered_oil2(), aes(x = Borough)) + geom_bar(aes(fill = Building.Type))
    
    borough = filtered_oil2()%>%
      group_by(., Borough) %>%
      summarize(., cnt = n()) %>%
      as.data.frame
    
    gvisColumnChart(borough, options = list(width = 400, height=300))
    
  })
  output$Btype = renderGvis({
    
    buildingT = filtered_oil2()%>%
      group_by(., Building.Type)%>%
      summarise(., BuildingType = n())
    
    gvisPieChart(buildingT)
  })
  
})
