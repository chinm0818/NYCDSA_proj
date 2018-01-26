#
# Shiny app for NYC_oil project
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#



library(leaflet)

ui = bootstrapPage(
  tags$style(type = 'text/css', 'html, body {width:100%; height100%}'),
  plotOutput('map', width = '800px', height = '400px'),
  absolutePanel(top = 10, left = 10,
                sliderInput('year',
                            label = 'Year Range',
                            min = 2018,
                            max = 2030,
                            value = c(2018, 2020)),
                selectInput('gas',
                            'Gas Provider',
                            choice = c('All', 'Con Edison', 'National Grid')),
                selectInput('boro',
                            'Select Borogh',
                            choice = c('All', 'Bronx', 'Brooklyn', 'Manhattan', 'Queens', 'Staten Island'))
  ),
  absolutePanel(top = 10, right = 10,
                htmlOutput('Btype'))
                #htmlOutput('count_data'))
)

