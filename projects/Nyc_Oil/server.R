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
  
  filtered_oil2 = reactive({ 
    oil2 %>%
      filter(., Retirement >= input$year[1] & Retirement <= input$year[2]) %>%
      filter(., Natural.Gas.Utility..Con.Edison.or.National.Grid == gas_select())
    
  })
  
   
  output$NYC_map <- renderPlot({
 #don't forget that reactive is a func. so it will need '()' when referring to it   
    combined_map2 = ggplot() + 
      geom_polygon(data = counties, aes(x=long, y=lat, group = group)) +
      geom_point(data = filtered_oil2(), aes(x = Longitude, y = Latitude, color = Building.Type)) + 
      theme(axis.title.x = element_blank(),
            axis.text.x=element_blank(),
            axis.ticks = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y=element_blank()
      )  
  combined_map2
    
  })
  output$count_data = renderPlot({
    ggplot(data = filtered_oil2(), aes(x = Borough)) + geom_bar(aes(fill = Building.Type))
  })
  
})
