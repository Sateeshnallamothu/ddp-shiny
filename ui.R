#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(ggmap)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  tags$h3("Interactive location information using Google geocode service."),
  h5("Help text"),
  helpText("Enter any location name such as address, city, state, postal code, place, landmark, country etc. ", 
           "to zoom the map appropriately and mark the location. Click the marker for more details. Use +/- for further zoom. ",
           "Clear All button will reset the map to star over. "),
  leafletOutput("map"),
  absolutePanel(top = 135, right = 10,
                textInput("loc","Input Location","Normal IL") ,
                actionButton("show", "Show Location"),
                actionButton("clear","Clear All")
  )
  
))
