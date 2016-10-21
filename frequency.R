# Sample script to scrape table from webpage
library(rvest)    # Load `rvest` package
library(dplyr)    # Load `dplyr` pacakge
library(stringr)  # Load `stringr` package

setwd("~/Documents/DA/Projects/friends/")
file_url <- '~/Documents/DA/projects/friends/transcripts/season01/0108.html'

# characters <- c("Chandler", "Joey", "Monica", "Phoebe", "Ross")

Actors <- file_url %>%
  read_html() %>%
  html_nodes(css = 'b') %>%
  html_text()

cleanlist <- function(x){
  gsub(pattern = "(.*):.*" ,replacement = "\\1", x = x)
}

Actors <- sapply(X = Actors, FUN = cleanlist, USE.NAMES = FALSE)
Actors <- str_trim(string = Actors)
Actors <- gsub(pattern = "^$", replacement = NA_character_, x = Actors)
Actors <- as.data.frame(x = Actors, stringsAsFactors = F)
Actors <- filter(.data = Actors, Actors == "Chandler" |
                   Actors == "Joey" | Actors == "Monica" | Actors == "Phoebe" |
                   Actors == "Rachel" | Actors == "Ross")

barplot(height=table(Actors))
