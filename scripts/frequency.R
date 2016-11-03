# Sample script to scrape table from webpage
library(rvest)    # Load `rvest` package
library(stringr)  # Load `stringr` package

WorkDir <- "C:/DA/Projects/F.R.I.E.N.D.S/"
setwd(dir = paste0(WorkDir, "scripts/"))

season_num <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10")
files_path <- paste0(WorkDir, "transcripts/season", season_num, "/")
files_list <- lapply(X = files_path, FUN = list.files)

all_episodes <- mapply(FUN = function(x,y) paste0(x,y),
                       x = files_path, y=files_list) %>% 
                unlist(use.names = F)
num_episodes <- length(all_episodes)

friends <- c("chandler", "joey", "monica",
             "phoebe", "rachel", "ross")
plot_colors <- c("burlywood4", "tan2", "gold3",
                 "brown", "green3", "gray")

Lead_Characters_allep <- NA # Initialize

num_dialogues <- matrix(data = NA, nrow = num_episodes, ncol = length(friends))

for(i in 1:num_episodes) {

  file_url <- all_episodes[i]

  all_Characters <- file_url %>%
    read_html() %>%
    html_nodes(css = 'b, p') %>%
    html_text()

  # Define function `cleanlist`
  cleanlist <- function(x) gsub(pattern = "(.*):.*", 
                                replacement = "\\1", x = x)

  all_Characters <- sapply(X = all_Characters, FUN = cleanlist, USE.NAMES = F) %>% 
                    str_trim() %>% 
                    gsub(pattern = "^$", replacement = NA_character_) %>% 
                    tolower()
  
  Lead_Characters <-
    all_Characters[all_Characters %in% friends]

  if(sum(!is.na(x = Lead_Characters)) != 0) {
    
    png(paste0(WorkDir,"plots/episode", i, "frequency_plot.png"),
        width = 800, height = 600)
    barplot(height=table(Lead_Characters), xlab = "Lead Characters",
            ylab = "Number of Dialogues", col = plot_colors,
            main = "Number of Dialogues in F.R.I.E.N.D.S TV series (1994-2004)",
            sub = paste0("Episode",i), font.sub = 3)
    dev.off()

  } else warning(paste0("fail for", i))
  
  Lead_Characters <- tolower(x = Lead_Characters)
  
  # Number of dialogues by each character in each episode
  num_dialogues[i,] <- sapply(X = friends,
                              function(x) length(all_Characters[all_Characters %in% x]))
  
  # Plot number of dialogues versus friends for each episode

Lead_Characters_allep <- c(Lead_Characters_allep, Lead_Characters)
  
}

# Convert matrix `num_dialogues` into data.frame
# and name its columns
num_dialogues <- as.data.frame(x = num_dialogues)
names(num_dialogues) <- friends

# Plot number of dialogues versus episode for each friend
for(j in 1:length(friends)){
  
  png(paste0(WorkDir,"plots/#dial_vs_ep_", friends[j],".png"), width = 800, height = 600)
  plot(x = 1:num_episodes, y = num_dialogues[,j], type = "l",
       main = paste0("Number of Dialogues vs. Episode by ", friends[j]) ,
       xlab = "Episode Number", ylab = "Number of Dialogues in each episode",
       col = plot_colors[j], lwd = 3,
       xlim = c(1,num_episodes), ylim = c(0, 250))
  dev.off()
  
}

# Plot number of dialogues versus episode for each friend in the same plot
png(paste0(WorkDir,"plots/#dial_vs_ep_allfriends.png"), width = 800, height = 600)
plot(x = 1:num_episodes, y = num_dialogues[,j], type = "l",
     main = paste0("Number of Dialogues vs. Episode by ", friends[j]),
     xlab = "Episode Number", ylab = "Number of Dialogues in each episode",
     col = plot_colors[j], lwd = 3,
     xlim = c(1,num_episodes), ylim = c(0, 250))

for(k in 2:length(friends))
  lines(x = 1:num_episodes, y = num_dialogues[,k], col = plot_colors[k])
dev.off()

# Plot numr of dialogues summed for all episodes versus friend
png(paste0(WorkDir,"plots/allep_frequency_plot.png"), width = 800, height = 600)
barplot(height=table(Lead_Characters_allep), xlab = "Lead Characters",
        ylab = "Number of Dialogues", col = plot_colors,
        main = "Number of Dialogues in F.R.I.E.N.D.S TV series (1994-2004)",
        sub = "Complete Series", font.sub = 3)
dev.off()