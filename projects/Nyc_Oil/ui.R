#
# Shiny app for NYC_oil project
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(
    sidebarUserPanel("Your Name"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))),
    selectizeInput("selected",
                   "Select Item to Display",
                   choice = c('All',
                   'Con Edison', 'National Grid'))
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              "to be replaced with map and histogram"),
      tabItem(tabName = "data",
              "to be replaced with datatable"))
  )
))