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
        
        output$n_grams_plot <-  renderPlot({
                b_grams <- filtered_ds() %>%
                        unnest_tokens(bigram,
                                      description,
                                      token = "ngrams",
                                      n = 2) %>%
                        count(bigram, sort = T)
                
                
                b_grams_count <- b_grams %>%
                        separate(bigram, c("word1", "word2"), sep = " ") %>%
                        filter(!word1 %in% stop_words$word) %>%
                        filter(!word2 %in% stop_words$word) %>%
                        # filter(!is.na(word1)) %>%
                        # filter(!is.na(word2)) %>%
                        unite(bigram, word1, word2, sep = " ") %>%
                        # head(10) %>%
                        mutate(bigram = fct_reorder(bigram, n)) %>%
                        head(10) %>%
                        ggplot(aes(bigram, n)) +
                        geom_col() +
                        coord_flip()
                b_grams_count
                
        })
        output$download_csv <- downloadHandler(
                filename = "brighter_set.csv", 
                content = function(file){
                        write.csv(filt_data(), file)
                }
        )
})

# Run the application
# shinyApp(ui = ui, server = server)
