# Load Packages
load_pacakges <- c("dplyr", "tidyr", "readr", "stringr",
                   "magrittr", "ggplot2", "rvest", "lubridate", 
                   "rlist", "caret", "broom")
lapply(load_pacakges, require, character.only = TRUE)

# Set Working Directory
WorkDir <- "C:/DA/Projects/F.R.I.E.N.D.S/"
setwd(dir = paste0(WorkDir, "scripts/"))

# Get the path of transcript files for all episodes
season_num <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10")
files_path <- paste0(WorkDir, "transcripts/season", season_num, "/")
files_list <- lapply(X = files_path, FUN = list.files)

all_episodes <- mapply(FUN = function(x,y) paste0(x,y),
                       x = files_path, y=files_list) %>% 
  unlist(use.names = F)

# Get total number of episodes in this T.V series
num_episodes <- length(all_episodes)

# Define a character vector for all six Lead characters
# In Alphabetical order, trying to be unbiased :P
friends <- c("CHANDLER", "JOEY", "MONICA", "PHOEBE", "RACHEL", "ROSS")

# Set colors to create plots/graphs
plot_colors <- c("burlywood4", "tan2", "gold3", "brown", "green3", "gray")

# Initialize vector `Lead_Characters_allep`
Lead_Characters_allep <- NA 

# Initialize matrix `num_dialogues`
num_dialogues <- matrix(data = NA, nrow = num_episodes, ncol = length(friends))

# Run `for` loop on each episode to extract and plot data
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
    toupper()
  
  Lead_Characters <-
    all_Characters[all_Characters %in% friends]
  
  # If data is extracted successfully for an episode, enter the 'if' section
  # If not, enter the 'else' section and display warning message
  if(sum(!is.na(x = Lead_Characters)) != 0) {
    
    # Plot #Dialogues vs. Lead Character for each episode
    # One Bar Plot per loop
    png(paste0(WorkDir,"plots/episode", i, "frequency_plot.png"),
        width = 800, height = 600)
    barplot(height = table(Lead_Characters), xlab = "Lead Characters",
            ylab = "#Dialogues", col = plot_colors,
            main = "Number of Dialogues in F.R.I.E.N.D.S T.V series (1994-2004)",
            sub = paste0("Episode",i), font.sub = 3)
    dev.off()
    
  } else warning(paste0("data scraping unsuccessful for episode ", i))
  
  # Store #Dialogues by each Lead character per episode in `num_dialogues`
  num_dialogues[i,] <- sapply(X = friends,
                              function(x) length(Lead_Characters[Lead_Characters %in% x]))
  
  # Store the list of all repeated Lead character names for 
  # all episodes in a single character vector `Lead_Characters_allep`
  Lead_Characters_allep <- c(Lead_Characters_allep, Lead_Characters)
  
}

# Convert matrix `num_dialogues` into data.frame and name its columns
num_dialogues <- as.data.frame(x = num_dialogues)
names(num_dialogues) <- friends

# Plot `#Dialogues` vs. `Episode number` for each Lead Character
# This `for` loop runs six times, once for each Lead character
# Total six line plots, one per loop
for(j in 1:length(friends)){
  
  png(paste0(WorkDir,"plots/#Dialogues_vs_ep_", friends[j],".png"), 
      width = 800, height = 600)
  plot(x = 1:num_episodes, y = num_dialogues[,j], type = "l",
       main = paste0(" Number of Dialogues vs. Episode by ", friends[j]) ,
       xlab = "Episode Number", ylab = "#Dialogues in each episode",
       col = plot_colors[j], lwd = 3,
       xlim = c(1,num_episodes), ylim = c(0, 250))
  dev.off()
  
}

# Plot `#Dialogues` versus `Episode number` for all 
# six Lead characters in the same plot, unlike above plot
# Six line plots in single Chart
png(paste0(WorkDir,"plots/#Dialogues_vs_ep_allfriends.png"), 
    width = 800, height = 600)
plot(x = 1:num_episodes, y = num_dialogues[,j], type = "l",
     main = paste0("Number of Dialogues vs. Episode by ", friends[j]),
     xlab = "Episode Number", ylab = "#Dialogues in each episode",
     col = plot_colors[j], lwd = 3,
     xlim = c(1,num_episodes), ylim = c(0, 250))

for(k in 2:length(friends))
  lines(x = 1:num_episodes, y = num_dialogues[,k], col = plot_colors[k])
dev.off()

# Plot #Dialogues summed for all episodes vs. each Lead Character
# Single Bar Plot
png(paste0(WorkDir,"plots/allep_frequency_plot.png"), 
    width = 800, height = 600)
barplot(height=table(Lead_Characters_allep), xlab = "Lead Characters",
        ylab = "#Dialogues", col = plot_colors,
        main = "Number of Dialogues in F.R.I.E.N.D.S T.V series (1994-2004)",
        sub = "Complete Series", font.sub = 3)
dev.off()

# Bar plot using `ggplot2` package
# Convert the character vector `Lead_Characters_allep` 
# into `data.frame` and change its column names
df <- as.data.frame(table(Lead_Characters_allep))
names(df) <- c("FRIENDS", "Number_of_Dialogues")
# Set name and dimensions for the barplot
png(paste0(WorkDir,"plots/allep_frequency_ggplot2.png"), 
    width = 850, height = 550)
p <- ggplot(data = df, aes(x = FRIENDS, y = Number_of_Dialogues, fill = FRIENDS)) +
  # Set plot type to Bar plot and adjust width of bars
  geom_bar(stat = "identity", width = 0.7) +
  # Set theme to `minimal`
  theme_minimal() +
  # Set title for plot and lables for x & y axes
  labs(title = "Total Number of Dialogues by Lead Characters
       \n in F.R.I.E.N.D.S T.V series (1994-2004)", 
       x = NULL, y = "Number of Dialogues") +
  # Set Title and x & y axes tick mark labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12), 
        axis.title = element_text(face = "bold", size = 16),
        #Remove legend
        legend.position = "none") +
  # Convert vertical barplot into horizontal one
  coord_flip()
p
dev.off()
