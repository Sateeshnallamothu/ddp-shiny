#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
setLoc<-function(addr){
  if (addr==""){
    return(data.frame(lat=0, long=0, accuracy=NA, formatted_address=NA, address_type=NA, status=NA,
                      zoom=NA,provider='openStreetMap',geomAcc=NA))
  } 
  std_addr(addr)
}
## standardize the address using google geocode server.
#  this funtion also sets the map zoop level and provider name based on the type 
#  of the location/address entered
# for additional info, visit https://developers.google.com/maps/documentation/javascript/geocoding

std_addr<-function(addr){ 
  #use the gecode function to find the lat/long, accuracy and type of the input
  geo_reply = geocode(addr, output='all', messaging=TRUE, override_limit=TRUE)
  #extract the features that we need from the returned list
  answer <- data.frame(lat=NA, long=NA, accuracy=NA, formatted_address=NA, address_type=NA, status=NA,
                       zoom=NA,provider='openStreetMap',geomAcc=NA)
  answer$status <- geo_reply$status
  
  #return Na's if we didn't get a match:
  if (geo_reply$status != "OK"){
    return(answer)
  }
  #otherwise, extract what we need from the Google server reply into a dataframe:
  answer$lat <- geo_reply$results[[1]]$geometry$location$lat
  answer$long <- geo_reply$results[[1]]$geometry$location$lng
  answer$geomAcc <-  geo_reply$results[[1]]$geometry$location_type
  
  if (length(geo_reply$results[[1]]$types) > 0){
    answer$accuracy <- geo_reply$results[[1]]$types[[1]]
  }
  answer$address_type <- paste(geo_reply$results[[1]]$types, collapse=',')
  answer$formatted_address <- geo_reply$results[[1]]$formatted_address
  ## assgin zoom levels based on the location accuracy. 
  zoomdata<-data.frame(accuracy=c('street_address','route','postal_code','locality','sublocality',
                                  'political','administrative_area_level_3','administrative_area_level_2',
                                  'administrative_area_level_1','country','continent','premise','subpremise',
                                  'establishment','park','airport','amusement_park','neighborhood'),
                       zoomlvl=c(18,16,15,13,14,17,12,11,9,5,4,18,18,18,18,18,18,17))
  answer$zoom<-zoomdata$zoomlvl[match(answer$accuracy,zoomdata$accuracy)]
  if (is.na(answer$zoom)) {
    answer$zoom <- 7  ## default zoom
  }
  # assign provider based on the accuracy/zoom level
  if (answer$zoom %in% c(5,4,6)) {
     answer$provider <- 'Esri.WorldGrayCanvas'
  }
  return(answer)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  # the show bottom will recalcuates the geo location information for the input
  point <- eventReactive(input$show, {
     setLoc(input$loc)
  }, ignoreNULL = FALSE)
  
  
  observe({
    # Incremental changes to the map (in this case, add more markers based on input
    # should be performed in an observer. Each independent set of things that can change
    # should be managed in its own observer. Note that the 'loc' input reactive variable will not
    # influence this observer. Only 'point' reactive variable will influence this. 
    
    #lbl<-isolate({input$loc})
    #format popup content and label
    popText<-paste(sep="<br/>",point()$formatted_address,
                   paste('Location Type:',point()$accuracy,point()$geomAcc,sep=' '),
                   'Lat/Long:',paste(sep='/',point()$lat,point()$long))
    lbl<-point()$formatted_address
    ## use leafletproxy to  modify a map that's already running in the page. 
    ## this will help us preserve all the previus locations entered.
    leafletProxy("map",data=point()) %>% setView(lat=point()$lat,lng=point()$long,zoom=point()$zoom) %>%
      addProviderTiles(providers$OpenStreetMap,  
                          options = tileOptions(noWrap = TRUE,minZoom=0,maxZoom=19)) %>%
          addMarkers(popup=popText,label=lbl,clusterOptions=markerClusterOptions(),
                labelOptions = labelOptions(noHide = T, textOnly = TRUE,style = list("color" = "red")))
  })
  
  observeEvent(input$clear,{
    # clear all markers. delay the observer until the clear button.
    leafletProxy("map",data=point()) %>% clearMarkerClusters()%>%setView(lat=0,lng=0,zoom=1)
    
  })
  #Initia map
  output$map <-  renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(quakes) %>% setView(lat=0,lng=0,zoom=2) %>% addTiles() 
  })
  
})
