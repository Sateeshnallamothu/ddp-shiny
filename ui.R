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
  h5("Help text:"),
  helpText("Enter any one of these from any where in the world: Full or partial address, city, state, postal code, place, landmark, country etc. ", 
           "This application will mark the location and dynamically zoom the map appropriately. Click the marker for more details. Use +/- for further zoom. ",
           "All the marker will be retained. Clear All button will reset the map to star over. "),
  p("E.g: 'Taj Mahal', 'JFK Airport', 'White House', 'Indian Parliament', 'Chicago', 'IL', 'Vijayawada', 'Victoria falls','520008','Germany','Millennium Park'."),
  h6("Developed by: Sateesh Nallamothu using google's geocode service."),
  leafletOutput("map"),
  absolutePanel(top = 170, right = 10,
                textInput("loc","Input Location","Normal IL") ,
                actionButton("show", "Show Location"),
                actionButton("clear","Clear All")
  )
  
))
