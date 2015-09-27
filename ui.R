library(shiny)
library(leaflet)

vars <- c("Tetragnatha acuta", "Tetragnatha brevignatha")
shinyUI(navbarPage("Evolab-Berkeley", id="nav",
                   
                   tabPanel("Interactive map",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css")
                                ),
                                
                                leafletOutput("map", width="100%", height="100%"),
                                
                                # Shiny versions prior to 0.11 should use class="modal" instead.
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = "auto",
                                              
                                              h2("Hawaii"),
                                              
                                              selectInput("species", "Species", vars))
                                ),
                                
                                tags$div(id="cite",
                                         'Data from Essig Museum'
                                )
                            )
                   )
                   

)