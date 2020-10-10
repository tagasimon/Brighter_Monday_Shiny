library(shiny)
library(shinyjs)
library(tidytext)
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)
library(glue)
# source("scrape_bm.R")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
        shinyjs::disable("scrape")
        
        filtered_ds <- reactive({
                # p <- getwd()
                # df <- read_csv(paste(p, "/df2.csv", sep = ""))
                df <- read_csv("https://raw.githubusercontent.com/tagasimon/Brighter_Monday_Shiny/main/df2.csv")
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
                gg_plot <- filtered_ds() %>%
                        unnest_tokens(word, description) %>%
                        anti_join(stop_words) %>%
                        count(word, sort = TRUE) %>%
                        filter(!is.na(word)) %>%
                        mutate(word = fct_reorder(word, n)) %>%
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
                gg_plot
        })

        output$download_csv <- downloadHandler(
                filename = "brighter_monday_ds.csv", 
                content = function(file){
                        write.csv(filtered_ds(), file)
                }
        )
})

# Run the application
# shinyApp(ui = ui, server = server)
