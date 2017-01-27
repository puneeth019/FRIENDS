### The One With the Data :D
# Load Packages
load_pacakges <- c("dplyr", "tidyr", "readr", "stringr",
                   "magrittr", "ggplot2", "rvest", "lubridate", 
                   "rlist", "caret", "broom", "reshape2")
lapply(load_pacakges, require, character.only = TRUE)

# Set Working Directory
WorkDir <- "C:/DA/Projects/F.R.I.E.N.D.S/"
setwd(dir = paste0(WorkDir, "scripts/"))

# Get the path of transcript files for all episodes
season_num <- c("01", "02", "03", "04", "05",
                "06", "07", "08", "09", "10")
files_path <- paste0(WorkDir, "transcripts/season", season_num, "/")
files_list <- lapply(X = files_path, FUN = list.files)

episodes_per_season <- lapply(X = files_list, FUN = length) %>% unlist()

season_num_per_episode <- rep(x = paste0("season ", season_num),
                          times = episodes_per_season)

all_episodes <- mapply(FUN = function(x,y) paste0(x,y),
                       x = files_path, y=files_list) %>% 
  unlist(use.names = F)

# Get total number of episodes in this T.V series
num_episodes <- length(all_episodes)

# Define a character vector for all six Lead characters
# In Alphabetical order, trying to be unbiased :D
FRIENDS <- c("CHANDLER", "JOEY", "MONICA",
             "PHOEBE", "RACHEL", "ROSS")

# Set colours to create plots/graphs
# These are colour-blind-friendly palettes
plot_colours <- c("#000000", "#E69F00", "#56B4E9",
                  "#009E73", "#F0E442", "#0072B2")

# Initialize vector `Lead_Characters_allep`
Lead_Characters_allep <- NA 

# Initialize matrix `num_dialogues`
num_dialogues <- matrix(data = NA, 
                        nrow = num_episodes, ncol = length(FRIENDS))

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
  
  all_Characters <- sapply(X = all_Characters,
                           FUN = cleanlist, USE.NAMES = F) %>% 
    str_trim() %>% 
    gsub(pattern = "^$", replacement = NA_character_) %>% 
    toupper()
  
  Lead_Characters <-
    all_Characters[all_Characters %in% FRIENDS]
  
  # If data is extracted successfully for an episode, enter the 'if' section
  # If not, enter the 'else' section and display warning message
  if(sum(!is.na(x = Lead_Characters)) != 0) {
    
    # Convert the character vector `Lead_Characters` 
    # into `data.frame` and change its column names
    dial_per_epi <- as.data.frame(table(Lead_Characters))
    names(dial_per_epi) <- c("FRIENDS", "Number_of_Dialogues")
    # Set name and dimensions for the plot
    png(paste0(WorkDir,"plots/episode",
               i, "frequency_plot.png"),
        width = 800, height = 500)
    p <- ggplot(data = dial_per_epi, aes(x = FRIENDS, 
                               y = Number_of_Dialogues,
                               fill = FRIENDS)) +
      # Set plot type to Bar plot and adjust width of bars
      geom_bar(stat = "identity") +
      # Set theme to `minimal`
      theme_minimal() +
      # Set title for plot and lables for x & y axes
      labs(title = "Number of Dialogues by Lead Characters
           \n F.R.I.E.N.D.S T.V series (1994-2004)",
           x = paste0("Episode #",i),
           y = "Number of Dialogues") +
      # Set text for Title, x & y axes labels
      theme(plot.title = element_text(size = 20, hjust = 0.5), 
            axis.text = element_text(face = "bold", size = 12),
            axis.title = element_text(face = "bold", size = 16),
            axis.title.y = element_text(vjust = 1.5),
            # legend position
            legend.position = "none") +
      # Set colours for bars
      scale_fill_manual(values = plot_colours) +
      # Convert vertical plot into horizontal one
      coord_flip()
    print(p)
    dev.off()
    
  } else warning(paste0("data scraping 
                        unsuccessful for episode #", i))
  
  # Store #Dialogues by each Lead character per episode in `num_dialogues`
  num_dialogues[i,] <- sapply(X = FRIENDS,
                              function(x) 
                                length(Lead_Characters[Lead_Characters %in% x]))
  

  
  # Store the list of all repeated Lead character 
  # names for all episodes in a single character 
  # vector `Lead_Characters_allep`
  Lead_Characters_allep <- c(Lead_Characters_allep, 
                             Lead_Characters)
  
}

# Convert matrix `num_dialogues` into data.frame and name its columns
dialogues <- data.frame(1:num_episodes, num_dialogues, 
                        season_num_per_episode)
names(dialogues) <- c("Episode_Number", FRIENDS, "season")


## Plot `#Dialogues` vs. `Episode number` for each Lead Character
## This `for` loop runs six times, once for each Lead character
## Total six line plots, one per loop
for(j in 1:length(FRIENDS)){
  
  # Set name and dimensions for the plot
  png(paste0(WorkDir, "plots/#Dialogues_vs_ep_", FRIENDS[j],".png"),
      width = 800, height = 500)
  p <- ggplot(data = dialogues,
              aes(x = Episode_Number, y = dialogues[,j+1])) +
    # Set plot type to line plot
    geom_line() +
    # Set title for plot and lables for x & y axes
    labs(title = paste0(" Number of Dialogues vs. Episode by ",
                        FRIENDS[j]),
         x = "Episode Number", y = "Number of Dialogues") +
    # Set text for Title, x & y axes labels
    theme(plot.title = element_text(size = 20, hjust = 0.5), 
          axis.text = element_text(face = "bold", size = 12),
          axis.title = element_text(face = "bold", size = 16),
          axis.title.y = element_text(vjust = 1.5),
          # legend position
          legend.position = "none")
  # Print the plot
  print(p)
  dev.off()
  
}


# Convert data.frame `dialogues` from wide to long format 
# using `tidyr::gather`
# This is done to create plots efficiently
#dialogues_long <- melt(data = dialogues, id.vars = "Episode_Number")
dialogues_long <- gather(data = dialogues, 
                         key = FRIENDS, 
                         value = dialogues_num, CHANDLER:ROSS)



## Plot `#Dialogues` versus `Episode number` for all 
## six Lead characters in the same plot, unlike above plot
## Six line plots in a single Chart
p <- ggplot(data = dialogues_long, aes(x = Episode_Number, 
                                       y = dialogues_num, 
                                       colour = FRIENDS)) +
  geom_line() +
  # Set colours for lines manually using `plot_colours`
  scale_colour_manual("FRIENDS", values = plot_colours) +
  # Set title for plot and lables for x & y axes
  labs(title = paste0("Number of Dialogues versus Episode Number"), 
       x = "Episode Number", y = "Number of Dialogues") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        axis.title.y = element_text(vjust = 1.5),
        # legend position
        legend.position = c(0.1,0.8))
# Set name and dimensions for the plot and save it
ggsave(paste0(WorkDir, "plots/#Dialogues_vs_ep_allfriends_lineplot.png"),
       width = 7, height = 5)



## Plot `Total #Dialogues` vs. `Episode number` 
## summed for all episodes for all Lead Character
## Single barplot
df <- as.data.frame(table(Lead_Characters_allep))
names(df) <- c("FRIENDS", "Number_of_Dialogues")
p <- ggplot(data = df,
            aes(x = FRIENDS, y = Number_of_Dialogues, 
                fill = FRIENDS)) +
  # Set plot type to Bar plot and adjust width of bars
  geom_bar(stat = "identity") +
  # Set theme to `minimal`
  theme_minimal() +
  # Set plot title and lables for x & y axes
  labs(title = "Total Number of Dialogues by Lead Characters
       \n F.R.I.E.N.D.S T.V series (1994-2004)", 
       x = NULL, y = "Number of Dialogues") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        # legend position
        legend.position = "none") +
  # Set colours for bars
  scale_fill_manual(values = plot_colours) +
  # Convert vertical barplot into horizontal one
  coord_flip()
# Set name and dimensions for the plot and save it
ggsave(paste0(WorkDir,"plots/allep_frequency_plot.png"),
       width = 7, height = 5)



## Plot Number of Dialogues per Episode
## vs. Episode number for all Lead Characters
## Stacked Barplot
p <- ggplot(data = dialogues_long, aes(x = Episode_Number, 
                                       y = dialogues_num, 
                                       fill = FRIENDS)) +
  # Set plot type to Bar plot and adjust width of bars
  geom_bar(stat = "identity") +
  # Set plot title and lables for x & y axes
  labs(title = "Number of Dialogues versus Episode Number", 
       x = "Episode Number", y = "Number of Dialogues") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        # legend position
        legend.position = c(0.1,0.78)) +
  # Set colours for bars
  scale_fill_manual("FRIENDS", values = plot_colours)
# Set name and dimensions for the plot and save it
ggsave(paste0(WorkDir, "plots/#Dialogues_vs_ep_allfriends_barplot.png"),
       width = 7, height = 5)



# Idead for more plots 
# Stacked Bar plot w.r.t Season# on X-axis (instead of episode#)
# Stacked 100% Bar plot w.r.t Episode# on x-axis
# Stacked 100% Bar plot w.r.t Season# on x-axis
# Circular area charts(for each Friend)
# Simple Pie Chart to show composition
# y - axis ( 0 to 1) Number of dia¬logues; x - axis episode number ( labels - six lead characters)
# Plot the above plot for all 10 seasons and for each season separately as well
# Plot the contribution (0 to 1) of each lead character per episode
# Rather than Episode Number in the plots, extract the actual name of episode and plot
# Or replace episode number with SXXEXX format
# Divide the main script into multiple small scripts for better understanding
