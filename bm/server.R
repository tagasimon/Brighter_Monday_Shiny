library(shiny)
library(shinyjs)
library(tidytext)
library(glue)
library(flexdashboard)
library(shinydashboard)
library(rvest)
library(tidyverse)
library(rebus)
library(janitor)
library(igraph)
library(ggraph)
library(shinycssloaders)
# source("scrape_bm.R")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
        shinyjs::disable("scrape")
        
        filtered_ds <- reactive({
                p <- getwd()
                df <- read_csv(paste(p, "/df2.csv", sep = ""))
                if (input$industry_select == "All") {
                        df
                } else{
                        df %>% filter(industry == input$industry_select)
                }
        })
        
        
        observeEvent(input$scrape, {
                showModal(modalDialog("Scraping Latest Jobs.........:)", footer = NULL))
                
                pathh <-
                        paste(getwd(), "/scrape_bm.R", sep = "")
                source(pathh)
                
                removeModal()
        })
        
        output$table <- DT::renderDataTable(DT::datatable({
                filtered_ds()
        }))
        
        output$word_count <- renderPlot({
                filtered_ds() %>%
                        unnest_tokens(word, description) %>%
                        anti_join(stop_words) %>%
                        count(word, sort = TRUE) %>%
                        mutate(word = fct_reorder(word, n)) %>%
                        filter(!is.na(word)) %>%
                        head(20) %>%
                        ggplot(aes(word, n, fill = word)) +
                        geom_col(show.legend = FALSE) +
                        coord_flip() +
                        labs(
                                y = "count",
                                x = "word",
                                title = glue("1. Most Common Words in ", {
                                        input$industry_select
                                }, " Industry")
                        )
        })

        output$download_csv <- downloadHandler(
                filename = "brighter_set.csv", 
                content = function(file){
                        write.csv(filtered_ds(), file)
                }
        )
})

# Run the application
# shinyApp(ui = ui, server = server)
