#
# Shiny app for NYC_oil project
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
 navbarPage(
   title = 'Oil Boiler Retirement',
   tabPanel('Map', 
       plotOutput("NYC_map", width = '100%'),
       sliderInput("year",
                   "Scheduled Retirement Year:",
                   min = 2018,
                   max = 2030,
                   value = c(2018, 2020)),
       selectInput("gas", "Gas Provider",
                   choices = c("All", "Con Edison", "National Grid"))),
   tabPanel('Analysis', plotOutput("count_data"))
  )
)
)