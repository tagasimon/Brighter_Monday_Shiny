library(rvest)
library(tidyverse)
library(rebus)
library(janitor)

url <- "https://www.brightermonday.co.ug/jobs?page="
path <- ".direction--row"
jobs_df_final <- NULL


for(i in 1:5){
        if(i == 1){
                final_url <- "https://www.brightermonday.co.ug/jobs"  
        }else{
                
                final_url <- paste(url, i, sep= "")
        }
        html_doc <- read_html(final_url)
        
        nodes <- html_nodes(html_doc, path)
        
        jobs  <- nodes %>%
                html_nodes("h3") %>%
                html_text()
        job_links <- nodes %>%
                html_nodes("a")
        indutry <- nodes %>% 
                html_nodes(".gutter-flush-under-lg") %>% 
                html_text()
        job_links <- job_links[1:length(job_links) - 1]
        
        
        jobs_df <- tibble(id = 1:length(html_attr(job_links, "href")),
                          jobs,
                          links = html_attr(job_links, "href"))
        
        jobs_df_final <- jobs_df_final %>% bind_rows(jobs_df)
        
        jobs_df_final
}

## Get Job Description
get_job_text <- function(url) {
        message(url)
        read_html(url) %>%
                html_nodes(".description-content__content p") %>%
                html_text()
}

## Get Job Industry
get_indu <- function(url) {
        # message(url)
        read_html(url) %>%
                html_nodes(".font-size-15+ .font-size-15 a") %>%
                html_text()
}

## Get Job Industry
get_job_type <- function(url) {
        # message(url)
        read_html(url) %>%
                html_nodes(".job-header__work-type a") %>%
                html_text()
}

jobs_df_final <- jobs_df %>%
        # head(5) %>%  ## -
        mutate(description = map(links, get_job_text)) %>%
        mutate(industry = map(links, get_indu)) %>%
        mutate(job_type = map(links, get_job_type))
jobs_df_final <- jobs_df_final %>% unnest(c(description,industry,job_type))

write_csv(jobs_df_final,"df2.csv")
