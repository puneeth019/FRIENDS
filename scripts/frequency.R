# Sample script to scrape table from webpage
library(rvest)    # Load `rvest` package
library(stringr)  # Load `stringr` package

WorkDir <- "~/DA/Projects/F.R.I.E.N.D.S/"
setwd(dir = paste0(WorkDir, "scripts/"))

season_num <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10")
files_path <- paste0(WorkDir, "transcripts/season", season_num, "/")
files_list <- lapply(X = files_path, FUN = list.files)

all_episodes <- mapply(FUN = function(x,y) paste0(x,y), x = files_path, y=files_list) %>% 
                unlist(use.names = F)
num_episodes <- length(all_episodes)

Lead_Characters_allep <- NA # Initialize

for(i in 1:num_episodes) {

  file_url <- all_episodes[i]

  all_Characters <- file_url %>%
    read_html() %>%
    html_nodes(css = 'b') %>%
    html_text()

  # Define function `cleanlist`
  cleanlist <- function(x) gsub(pattern = "(.*):.*" ,replacement = "\\1", x = x)

  all_Characters <- sapply(X = all_Characters, FUN = cleanlist, USE.NAMES = F) %>% 
                    str_trim() %>% 
                    gsub(pattern = "^$", replacement = NA_character_)
  
  Lead_Characters <- all_Characters[all_Characters %in% c("Chandler", "Joey",
                                                          "Monica", "Phoebe", "Rachel", "Ross")]

  if(sum(!is.na(x = Lead_Characters)) != 0) {
    png(paste0(WorkDir,"plots/episode", i, "frequency_plot.png"))
    barplot(height=table(Lead_Characters), xlab = "Lead Characters",
              ylab = paste0("Number of Dialogues"),
              col = c("lightblue", "mistyrose", "lightcyan",
                      "lightgreen", "lavender", "khaki"),
              main = "# Dialogues in F.R.I.E.N.D.S TV series (1994-2004)",
              sub = paste0("Episode",i), font.sub = 3)
    dev.off()
    } else warning("fail for episode", i)

  Lead_Characters_allep <- c(Lead_Characters_allep, Lead_Characters)

}

png(paste0(WorkDir,"plots/allep_frequency_plot.png"))
barplot(height=table(Lead_Characters_allep), xlab = "Lead Characters",
        ylab = "Number of Dialogues",
        col = c("lightblue", "mistyrose", "lightcyan", "lightgreen", "lavender", "khaki"),
        main = "# Dialogues in F.R.I.E.N.D.S TV series (1994-2004)",
        sub = paste0("Complete Series"), font.sub = 3)
dev.off()
