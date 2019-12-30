rm(list=ls(all=TRUE)) #start with empty workspace

# Load Packages
load_pacakges <- c("tidyverse", "rvest", "stringr", "magrittr")
lapply(load_pacakges, library, character.only = TRUE)

# Set Working Directory
WorkDir <- "F.R.I.E.N.D.S/"
setwd(dir = paste0(WorkDir, "scripts/"))

# Get the path of transcript files for all episodes
season_num <- c("01", "02", "03", "04", "05",
                "06", "07", "08", "09", "10")
files_path <- paste0(WorkDir, "transcripts/season", season_num, "/")
files_list <- lapply(X = files_path, FUN = list.files)

episodes_per_season <- lapply(X = files_list, FUN = length) %>% unlist()

season_num_per_episode <- rep(x = season_num,
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
# Six colours combo is used for versus character plots,
# as number of Characters are `Six`
plot_colours_six <- c("#000000", "#E69F00", "#56B4E9",
                      "#009E73", "#F0E442", "#0072B2")
# Ten Colours combo is used for versus Season plots,
# as number of seasons are `Ten`
plot_colours_ten <- c("#000000", "#E69F00", "#56B4E9", 
                      "#009E73", "#F0E442", "#0072B2",
                      "#D55E00", "#CC79A7", "#000000",
                      "#E69F00")


# Initialize vector `Lead_Characters_allep`
Lead_Characters_allep <- NA 

# Initialize matrix `num_dialogues`
num_dialogues <- matrix(data = NA, 
                        nrow = num_episodes, ncol = length(FRIENDS))

# Run `for` loop on each episode to extract and plot data
for(i in 1:num_episodes) {
  
  Lead_Characters <- all_episodes[i] %>%
    read_html() %>%
    html_nodes(css = 'b, p') %>%
    html_text() %>% 
    gsub(pattern = "(.*):.*", replacement = "\\1") %>% 
    str_trim() %>% 
    gsub(pattern = "^$", replacement = NA_character_) %>% 
    toupper() %>% 
    extract(. %in% FRIENDS)
  
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
    setwd(dir = paste0(WorkDir, "plots/"))
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
      scale_fill_manual(values = plot_colours_six) +
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

## Convert `Lead_Characters_allep` into `data.frame`
## and name its columns
Lead_Characters_allep <- as.data.frame(table(Lead_Characters_allep))
names(Lead_Characters_allep) <- c("FRIENDS", "Number_of_Dialogues")



## Plot `Total #Dialogues` vs. `Episode number` 
## summed for all episodes for all Lead Character
## Single barplot

# Set name and dimensions for the plot
png(paste0(WorkDir,"plots/allep_frequency_plot.png"),
    width = 800, height = 500)
setwd(dir = paste0(WorkDir, "plots/"))
p <- ggplot(data = Lead_Characters_allep,
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
  scale_fill_manual(values = plot_colours_six) +
  # Convert vertical barplot into horizontal one
  coord_flip()
print(p)
dev.off()



# Convert matrix `num_dialogues` into data.frame and name its columns
dialogues <- data.frame(1:num_episodes, num_dialogues, 
                        season_num_per_episode, 
                        stringsAsFactors = F)
names(dialogues) <- c("Episode_Number", FRIENDS, "season")
setwd(dir = paste0(WorkDir, "data/"))
write.csv(x = dialogues,
          file = 'dialogues.csv')



## Plot `#Dialogues` vs. `Episode number` for each Lead Character
## This `for` loop runs six times, once for each Lead character
## Total six line plots, one per loop
for(j in 1:length(FRIENDS)){
  
  # Set name and dimensions for the plot
  png(paste0(WorkDir, "plots/Dialogues_vs_ep_", FRIENDS[j],".png"),
      width = 800, height = 500)
  setwd(dir = paste0(WorkDir, "plots/"))
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
dialogues_long <- gather(data = dialogues, 
                         key = FRIENDS, 
                         value = dialogues_num, CHANDLER:ROSS)


## Plot `#Dialogues` versus `Episode number` for all 
## six Lead characters in the same plot, unlike above plot
# Set name and dimensions for the plot
png(paste0(WorkDir, 
           "plots/Dialogues_vs_ep_allfriends_lineplot.png"),
    width = 800, height = 500)
setwd(dir = paste0(WorkDir, "plots/"))
## Six line plots in a single Chart
p <- ggplot(data = dialogues_long, aes(x = Episode_Number, 
                                       y = dialogues_num, 
                                       colour = FRIENDS)) +
  geom_line() +
  # Set colours for lines
  scale_colour_manual(values = plot_colours_six) +
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
print(p)
dev.off()



## Plot Number of Dialogues per Episode
## vs. Episode number for all Lead Characters
# Set name and dimensions for the plot
png(paste0(WorkDir, 
           "plots/Dialogues_vs_ep_allfriends_barplot.png"),
    width = 800, height = 500)
setwd(dir = paste0(WorkDir, "plots/"))
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
  scale_fill_manual(values = plot_colours_six)
print(p)
dev.off()



# Calcualte #Dialogues vs season# for each Character
numdial_wrt_season <- dialogues %>%
  # Convert data.frame `dialogues` from wide to long format
  gather(key = "FRIENDS", 
         value = "dialogues_num", -Episode_Number, -season) %>% 
  group_by(season, FRIENDS) %>% 
  summarize(dialogues_num = sum(dialogues_num)) %>% 
  ungroup

# Set name and dimensions for the plot
png(paste0(WorkDir, "plots/Num_Dial_vs_season.png"),
    width = 800, height = 500)
setwd(dir = paste0(WorkDir, "plots/"))
p <- ggplot(data = numdial_wrt_season, 
            aes(x = season, y = dialogues_num, fill = FRIENDS)) +
  # Set plot type to Bar plot
  geom_bar(stat = "identity") +
  # Set plot title and lables for x & y axes
  labs(title = "Number of Dialogues vs Season", 
       x = "Season", y = "Number of Dialogues") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        # Set Panel Background fill and border
        panel.background = element_rect(fill = "white", colour = "black"),
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = "grey", linetype = "dotted")) +
  # Set colours for bars
  scale_fill_manual(NULL, values = plot_colours_six)
print(p)
dev.off()



# Calcualte % Dialogues vs season# for each Character
percdial_wrt_season <- numdial_wrt_season %>% 
  group_by(season) %>% 
  mutate(perc = dialogues_num / sum(dialogues_num) * 100) %>% 
  ungroup

# Set name and dimensions for the plot
png(paste0(WorkDir, "plots/Perc_Dial_vs_season.png"),
    width = 900, height = 500)
setwd(dir = paste0(WorkDir, "plots/"))
p <- ggplot(data = percdial_wrt_season, 
            aes(x = season, y = perc, fill = FRIENDS)) +
  # Set plot type to Bar plot
  geom_bar(stat = "identity") +
  # Set plot title and lables for x & y axes
  labs(title = "Percentage of Dialogues vs Season", 
       x = "Season", y = "Percentage of Dialogues") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        # legend position
        legend.position = "right",
        # Set Panel Background
        panel.background = element_rect(fill = "white", colour = "black"),
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = "grey", linetype = "dotted")) +
  # Set colours for bars
  scale_fill_manual(NULL, values = plot_colours_six)
print(p)
dev.off()



# Calcualte #Dialogues vs Character for each season
numdial_wrt_char <- dialogues %>% 
  gather(key = "FRIENDS",
         value = "dialogues_num", -Episode_Number, -season) %>% 
  group_by(FRIENDS, season) %>% 
  summarize(dialogues_num = sum(dialogues_num)) %>% 
  ungroup %>% 
  group_by(FRIENDS) %>%
  ungroup

# Set name and dimensions for the plot
png(paste0(WorkDir, "plots/Num_Dial_vs_character.png"),
    width = 900, height = 500)
setwd(dir = paste0(WorkDir, "plots/"))
p <- ggplot(data = numdial_wrt_char, 
            aes(x = FRIENDS, y = dialogues_num, fill = season)) +
  # Set plot type to Bar plot and adjust width of bars
  geom_bar(stat = "identity") +
  # Set plot title and lables for x & y axes
  labs(title = "Number of Dialogues vs. FRIENDS Characters", 
       x = NULL, y = "Number of Dialogues") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        # legend position
        legend.position = "right",
        # Set Panel background fill and border
        panel.background = element_rect(fill = "white", colour = "black"),
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = "grey", linetype = "dotted")) +
  # Set colours for bars
  scale_fill_manual(values = plot_colours_ten)
print(p)
dev.off()



# Calcualte % Dialogues vs Character for each season
percdial_wrt_char <- numdial_wrt_char %>% 
  group_by(FRIENDS) %>%
  mutate(perc = dialogues_num/sum(dialogues_num) * 100) %>% 
  ungroup

# Set name and dimensions for the plot
png(paste0(WorkDir, "plots/Perc_Dial_vs_character.png"),
    width = 900, height = 500)
setwd(dir = paste0(WorkDir, "plots/"))
p <- ggplot(data = percdial_wrt_char, 
            aes(x = FRIENDS, y = perc, fill = season)) +
  # Set plot type to Bar plot and adjust width of bars
  geom_bar(stat = "identity") +
  # Set plot title and lables for x & y axes
  labs(title = "Percentage of Dialogues vs. FRIENDS Characters", 
       x = NULL, y = "Percentage of Dialogues") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        # Set Panel background fill and border
        panel.background = element_rect(fill = "white", colour = "black"),
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = "grey", linetype = "dotted")) +
  # Set colours for bars
  scale_fill_manual(values = plot_colours_ten)
print(p)
dev.off()



# Assign Character Vector `FRIENDS` to 
# a new vector with name other than FRIENDS
FRIENDS_NEW <- FRIENDS

# Cyclic plots for each character - #Dialogues vs Season#
for(k in 1:length(FRIENDS)) {
  
  png(paste0(WorkDir, "plots/Cyclic_Num_Dial_vs_ep_", FRIENDS_NEW[k],".png"),
      width = 600, height = 500)
  setwd(dir = paste0(WorkDir, "plots/"))
  p <- ggplot(numdial_wrt_char %>% filter(FRIENDS == FRIENDS_NEW[k]),
              aes(x = season, y = dialogues_num, fill = season)) +
    # Set plot type to Bar plot and adjust width of bars
    geom_bar(stat = "identity") +
    # Set plot title and lables for x & y axes
    labs(title = "Number of Dialogues vs. Season", 
         x = FRIENDS_NEW[k], y = "Number of Dialogues") +
    # Set text for Title, x & y axes labels
    theme(plot.title = element_text(size = 20, hjust = 0.5), 
          axis.text = element_text(face = "bold", size = 12),
          axis.title = element_text(face = "bold", size = 16),
          # Set Panel background
          panel.background = element_rect(fill = "white", colour = "black"),
          panel.grid.major = element_line(colour = "grey"),
          panel.grid.minor = element_line(colour = "grey", linetype = "dotted")) +
    # Set colours for bars
    scale_fill_manual(values = plot_colours_ten) +
    coord_polar()
  print(p)
  dev.off()
  
}
