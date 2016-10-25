# Sample script to scrape table from webpage
library(rvest)    # Load `rvest` package
library(stringr)  # Load `stringr` package

WorkDir <- "~/Documents/DA/Projects/friends/"
setwd(dir = WorkDir)

season_num <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10")
files_path <- paste0(WorkDir, "transcripts/season", season_num, "/")

files_list <- lapply(X = files_path, FUN = list.files)
all_episodes <- mapply(FUN = function(x,y) paste0(x,y), x = files_path, y=files_list)
all_episodes <- unlist(x = all_episodes, use.names = F)
num_episodes <- length(all_episodes)

for(i in 1:num_episodes) {
  
file_url <- all_episodes[i]

Series_Characters <- file_url %>%
  read_html() %>%
  html_nodes(css = 'b') %>%
  html_text()

# Define function `cleanlist`
cleanlist <- function(x) gsub(pattern = "(.*):.*" ,replacement = "\\1", x = x)

Series_Characters <- sapply(X = Series_Characters, FUN = cleanlist, USE.NAMES = F)
Series_Characters <- str_trim(string = Series_Characters)
Series_Characters <- gsub(pattern = "^$",
                          replacement = NA_character_, x = Series_Characters)
Lead_actors <- Series_Characters[Series_Characters %in% c("Chandler", "Joey",
                                                          "Monica", "Phoebe", "Rachel", "Ross")]

if(sum(!is.na(x = Lead_actors)) != 0) {
png(paste0(WorkDir,"plots", "/Rplot", as.character(i), ".png"))
barplot(height=table(Lead_actors))
dev.off()
}

if(sum(!is.na(x = Lead_actors)) == 0) paste0("fail for", as.character(i))

}
