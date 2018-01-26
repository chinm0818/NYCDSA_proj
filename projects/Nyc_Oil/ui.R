#
# Shiny app for NYC_oil project
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#



library(leaflet)
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = 'Retiring NYC Oil Heating'),
  dashboardSidebar(
    
    sidebarUserPanel("Your Name"),
    sidebarMenu(
      
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))
    ), #End sidebar menu
    
    sliderInput('year', 
                label = 'Year Range',
                min = 2018,
                max = 2030,
                value = c(2018, 2020)),
    
    selectInput('gas',
                label = 'Gas Provider',
                choice = c('All', 'Con Edison', 'National Grid')),
    
    selectInput('boro', 
                label = 'Select Borogh',
                choice = c('All', 'Bronx', 'Brooklyn', 'Manhattan', 'Queens', 'Staten Island'))
  ), #END DBsidebar
  
  dashboardBody(
    tabItems(
      tabItem(tabName = 'map',
              leafletOutput('map', width = '800', height = '800'),
              textOutput('take_away'),
              absolutePanel(bottom = 10, right = 10, htmlOutput('Btype'))
              
      ),#End tabItem(map)
      tabItem(tabName = 'data',
              htmlOutput('count_data'),
              htmlOutput('time')
      )#End tabItem(data)
    )#End tabItems
  )#END DB body
)#END Dashboard
)#END ShinyUI

# fluidPage(
#   leafletOutput('map', width = '2000', height = '1000'),
#   absolutePanel(top = 10, left = 10,
#                 sliderInput('year',
#                             label = 'Year Range',
#                             min = 2018,
#                             max = 2030,
#                             value = c(2018, 2020)),
#                 selectInput('gas',
#                             'Gas Provider',
#                             choice = c('All', 'Con Edison', 'National Grid')),
#                 selectInput('boro',
#                             'Select Borogh',
#                             choice = c('All', 'Bronx', 'Brooklyn', 'Manhattan', 'Queens', 'Staten Island'))
#   ),
#   
#   fluidRow(htmlOutput('Btype'), plotOutput('count_data'))
#                
# )#END fluidPage



