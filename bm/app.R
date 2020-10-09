library(rvest)
library(tidyverse)
library(rebus)
library(janitor)
library(shiny)
library(shinycssloaders)
library(shinyjs)
library(tidytext)
## SOURCE SCRAPE FILE


it_link <- "https://www.brightermonday.co.ug/jobs/it-telecoms"
bank_link <-
    "https://www.brightermonday.co.ug/jobs/banking-finance-insurance"


# Define UI for application that draws a histogram
ui <- fluidPage(
    # Application title
    shinyjs::useShinyjs(),
    titlePanel("Brighter Monday Jobs - Insights"),
    theme = shinythemes::shinytheme('sandstone'),
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput(
                "industry_select",
                "Choose Industry",
                c(
                    "All",
                    "IT & Telecoms",
                    "Banking, Finance & Insurance",
                    "NGO, NPO & Charity",
                    "Hospitality & Hotel",
                    "Retail, Fashion & FMCG",
                    "Manufacturing & Warehousing",
                    "Real Estate",
                    "Healthcare"
                )
            ),
            actionButton("scrape", "Scrape Latest Jobs", class = "btn-success")
        ),
        
        # Show a plot of the generated distribution
        mainPanel(tabsetPanel(
            tabPanel("Table",
                     titlePanel("Datasets"),
                     DT::DTOutput("table")),
            tabPanel(
                "A lil Analysis",
                titlePanel("This is a Title"),
                plotOutput("word_count")
            ),
            tabPanel("API",
                     titlePanel("Work in Progress on the API"), )
        ))
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    shinyjs::disable("scrape")
    
    filtered_ds <- reactive({
        df <- read_csv("../df2.csv")
        if (input$industry_select == "All") {
            df
        }else{
            
        df %>%
            filter(industry == input$industry_select)
        }
    })
    
    
    observeEvent(input$scrape, {
        showModal(modalDialog("Scraping Latest Jobs.........:)", footer = NULL))
        
        pathh <- paste(getwd(), "/scrape_bm.R", sep = "")
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
            coord_flip()+
            labs(y="count",x = "word")
    })
}

# Run the application
shinyApp(ui = ui, server = server)
