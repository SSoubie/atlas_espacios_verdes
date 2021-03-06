library(shiny)
library(leaflet)
library(tidyverse)

aglomerados <- read_csv('data/aglomerados.csv')

# Mapbox stuff
base_url <- "https://api.mapbox.com/"
username <- "havb"
style_id <- "cjxavmsdb3z5m1cmolhba64y0"
acces_token <- "pk.eyJ1IjoiaGF2YiIsImEiOiJpSHhUWGVBIn0.IY5RvkA4-jqVtNxcsYioug"

map_url <- paste0(base_url, 
                  "styles/v1/", 
                  username, 
                  "/", 
                  style_id, 
                  "/tiles/256/{z}/{x}/{y}?access_token=",
                  acces_token) 



legend_colors <- c("#64d053", "#93a4f1", "#d55858")
legend_values <- c("espacio verde público", "distancia < 300 m ", "distancia > 300 m ")

ui <- navbarPage("Acceso a espacios verdes en ciudades argentinas",
           theme = "bootstrap.css",
           
           tabPanel("Mapa",
                    div(class="outer",
                        #tags$style(type = "text/css",
                        #           "#map {height: calc(100vh - 80px) !important;}"),
                        #leafletOutput("map"),
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css")
                        ),
                        
                        leafletOutput("map", width="100%", height="100%"),
                        absolutePanel(id = "controls", class = "panel panel-default", 
                                      fixed = TRUE,
                                      draggable = TRUE, top = "10%", left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto", cursor = "move",
                                      #h2("Inequidad en Argentina"),
                                      br(),
                                      selectInput(
                                        inputId = "aglomerado",
                                        label = "Aglomerado urbano:",
                                        choices = aglomerados$aglomerado,
                                        selectize = FALSE
                                      )
                                
                        )
                    )
           ),
           tabPanel("Info",
                    fluidRow(
                        column(12,
                               wellPanel(
                                   includeMarkdown("info.md"))
                        )
                    )
           )
           
)




################################################################################
# Server
################################################################################

server = function(input, output) {
  output$map <- renderLeaflet({
    leaflet() %>% 
      setView(lng = -58.581604, lat = -34.703708, zoom = 10) %>% 
      addTiles(urlTemplate = map_url,
               options = tileOptions(minZoom=7, maxZoom=15)) %>% 
      #Agregamos leyenda
      addLegend("bottomright", 
                colors = legend_colors, 
                labels = legend_values,
                title = "Distancia (desde centro de radio censal)",
                opacity = 1)
  })
  
  aglo_elegido <- eventReactive(input$aglomerado, {
    
    filter(aglomerados, aglomerado == input$aglomerado)
  })
  
  
  observe({
    proxy <- leafletProxy("map")
    proxy %>% setView(lat = aglo_elegido()$lat,
                      lng = aglo_elegido()$lon,
                      zoom = 12)
  })
    
}


################################################################################
# run app
shinyApp(ui, server)



