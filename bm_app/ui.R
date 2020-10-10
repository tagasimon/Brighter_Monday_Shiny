library(shiny)
library(shinyjs)
library(tidytext)
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)
library(glue)
## SOURCE SCRAPE FILE

# Define UI for application that draws a histogram
ui <- fluidPage(
    # Application title
    shinyjs::useShinyjs(),
    titlePanel("Make Your Monday Even Brighter??"),
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
                ),
                selected = "All"
            ),
            downloadButton("download_csv", "Download Dataset", class = "btn-success"),
            actionButton("scrape", "Scrape Latest Jobs", class = "btn-danger")
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            titlePanel("Jobs - Insights"),
            tabsetPanel(
                tabPanel(
                    "A lil Analysis",
                    titlePanel("1. Common Words Found"),
                    plotOutput("word_count") %>%
                        withSpinner(),
                ),
                tabPanel("Datasets",
                         titlePanel("Datasets"),
                         DT::DTOutput("table")),
                tabPanel("API",
                         titlePanel("Work in Progress on the API"),)
            )
        )
    )
)
