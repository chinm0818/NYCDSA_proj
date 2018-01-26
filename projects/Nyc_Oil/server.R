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
district = readOGR("nycc.shp", layer = "nycc")#nyc council district map
oil1 = read.csv('oil_boilers.csv')#alldata
oil2 = oil1 %>%
  filter(., !is.null(Latitude))
dummy = read.csv('dummy.csv')#df of zero values
# nyc_base = ggplot() + geom_polygon(data = counties, aes(x=long, y=lat, group = group)) 
district2 <- spTransform(district, CRS("+proj=longlat +datum=WGS84")) #transform coodtype to Lat Lng


shinyServer(function(input, output) {
  
#let's try to set up our reactive elements:
  
  
  gas_select = reactive({
    switch (input$gas,
            "Con Edison" = "Con Edison",
            "National Grid" = "National Grid",
            "All" = c("Con Edison", "National Grid"))#END Switch
  })#END reactive
  
  boro_select = reactive({
    switch(input$boro,
           "All" = c("Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island"),
           "Manhattan" = "Manhattan",
           "Bronx" = "Bronx",
           "Brooklyn" = "Brooklyn",
           "Queens" = "Queens",
           "Staten Island" = "Staten Island")
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
  
  map_location = reactive({
    switch(input$boro,
           "All" = c(40.69, -73.8, 11),
           "Manhattan" = c(40.7831, -73.9712, 12),
           "Bronx" = c(40.8448, -73.8648, 12),
           "Brooklyn" = c(40.6782, -73.9442, 12),
           "Queens" = c(40.7, -73.7949, 12),
           "Staten Island" = c(40.5795, -74.1502, 12))
  })


    
  filtered_oil2 = reactive({
    oil2 %>%
      filter(., Borough %in% boro_select()) %>%
      filter(., Retirement >= input$year[1] & Retirement <= input$year[2]) %>%
      filter(., Natural.Gas.Utility..Con.Edison.or.National.Grid %in% gas_select())
    
  })
  
  filtered_oil1 = reactive({
    oil1 %>%
      filter(., Borough %in% boro_select()) %>%
      filter(., Retirement >= input$year[1] & Retirement <= input$year[2]) %>%
      filter(., Natural.Gas.Utility..Con.Edison.or.National.Grid %in% gas_select())
    
  })
  
  consumption = reactive ({
    filtered_oil1() %>%
    group_by(., Borough) %>%
    summarize(., Fuel.Consumption = sum(Average.Consumption), Gas.Sales = sum(Dollars.Gas))
    
  })
  
 # leaflet map with geo and data layers 
  output$map <- renderLeaflet({
    
    leaflet(oil2) %>%
      addTiles(urlTemplate = 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_nolabels/{z}/{x}/{y}.png') %>%
      addCircles(color = 'red') 
    
  })
  
  # putting in leaflet proxy to control map (faster?)
  
  observe({
    req(filtered_oil2()) #req func to require non empty df
    leafletProxy('map', data = filtered_oil2()) %>%
      clearShapes() %>%
      addCircles(color = 'red') %>%
      addPolylines(data = counties[map_select(),]) %>%
      setView(lat = map_location()[1], lng = map_location()[2], zoom = map_location()[3])
      #addPolylines(data = district2) #leave this out for now. #later add option to toggle districts off and on
  })
  
  # #plotting in ggplot keep incase leaflet gets funky again
  
  # output$map = renderPlot({
  #   ggplot() + 
  #     geom_polygon(data = counties[map_select(),], aes(x=long, y=lat, group = group)) +
  #     geom_polygon(data = district2, aes(x = long, y=lat, group = group, fill = 'blue', alpha = 0.2)) +
  #     geom_point(data = filtered_oil2(), aes(x = Longitude, y = Latitude, color = 'red'))
  # })
  
 
    
    # output$count_data =  renderGvis({
    #   
    #   if(nrow(filtered_oil1()) > 0){
    #   borough = filtered_oil1() %>%
    #       group_by(., Borough) %>%
    #       summarize(., cnt = n())%>% #sum of anything just to get a zero val
    #       as.data.frame
    #   } else {
    #   borough = dummy %>%
    #       group_by(., Borough) %>%
    #       summarize(., cnt = sum(City.Council.District)) %>%
    #       as.data.frame
    #   }#END Conditional
    #   
    #   gvisColumnChart(borough, options = list(width = 400, height=300)) 
    #   })#END Googlevis chart render
    

  output$count_data = renderGvis({
    
    # ggplot(consumption, aes(x = Borough, y = Fuel.Consumption)) + geom_bar(stat = 'identity') +
    #   scale_x_continuous("Borough", breaks = 1:5, labels=c("Mon","Tues","Wed","Th","Fri"))
    
    gvisTable(consumption())
           
  })#END  chart render

  output$take_away = renderText({
    
    paste("Between the years", input$year[1],"and", input$year[2],"$", consumption()[dim(consumption())[1],dim(consumption())[2]], "of Natural gas can be sold")
  })#END  chart render
  
  
  output$Btype = renderGvis({
    
    buildingT = filtered_oil1()%>%
      group_by(., Building.Type)%>%
      summarise(., BuildingType = n())
    
    gvisPieChart(buildingT)
  })#END Gvisrender
  
  output$time = renderGvis({
    time = filtered_oil1() %>%
      group_by(., Borough, Retirement) %>%
      summarise(., Fuel.Consumption = sum(Average.Consumption))
    
    gvisLineChart(time)
  })
  
})#END Shiny server


# price of a MMbtu of gas was about 3 dollars in july 2017.* https://www.eia.gov/naturalgas/weekly/

