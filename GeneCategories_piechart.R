##################################################################################################################
### This script reads in the BOV_TB_categories file and Mb gene lists, and makes pie charts of gene categories ###
##################################################################################################################

### Libraries.
library(ggplot2)
library(ggrepel)
library(RColorBrewer)

### Functions.
# Make dataframe with percentages of vector items. 
make_df_perc <- function(input_vector){
  
  # Get vector names and counts.
  vector_names <- c()
  vector_counts <- c()
  for (i in 1:length(table(input_vector))){
    vector_names <- c(vector_names, names(table(input_vector)[i]))
    vector_counts <- c(vector_counts, as.numeric(table(input_vector)[i]))
  }
  # Calculate percentage and make dataframe.
  vector_perc <- round((vector_counts / sum(vector_counts)) * 100, 2)
  vector_df <- as.data.frame(cbind(vector_counts, vector_names, vector_perc))
  colnames(vector_df) <- c("Counts", "Categories", "Perc")
  
  # Order the data frame
  vector_df$Perc <- as.numeric(vector_df$Perc)
  vector_df <- vector_df[order(vector_df$Perc, decreasing = TRUE),]
  
  return(vector_df)
}
# Plot piechart from a dataframe with items and percentages. 
plot_pie <- function(plot_df){
  
  plot_df$Perc <- as.numeric(plot_df$Perc)
  # Get the desired number of colours.
  number_of_colors <- nrow(plot_df)
  mycolors <- colorRampPalette(brewer.pal(8, "Set2"))(number_of_colors)
  
  # Create the pie chart:
  genes_pie <- ggplot(plot_df, aes(x="", y=Perc, fill=Categories)) + geom_bar(stat="identity", width=1) + # basic bar plot.
    coord_polar("y", start=0) + geom_text(aes(x = 1.1, label = paste0(round(as.numeric(Perc), 2), "%")),  # x defines the text distance from the center. 
                                          position = position_stack(vjust = 0.5),
                                          check_overlap = TRUE) + # If labels overlap, don't plot them.
    theme_void() +
    labs(x = NULL, y = NULL, fill = NULL) +
    scale_fill_manual(values = mycolors, breaks = as.character(plot_df$Categories)) +  # Rearrange legend on decreasing freq.
    theme(plot.margin = unit(c(10,5,10,5), "mm"))
  
  return(genes_pie)
  
}

#### Input files.
tbbov_df <- as.data.frame(read.csv("data/mbovis_categories.csv"))
tbbov_df$Rv_tag <- toupper(tbbov_df$Rv_tag) 
tbbov_df$Mb_tag <- toupper(tbbov_df$Mb_tag)
# Read input gene lists of mb genes.
up_list <- toupper(readLines("results/BOVTBcommonup.txt"))
down_list <- toupper(readLines("results/BOVTBcommondown.txt"))

### 1. Make dataframes with Mb tags and categories for the Mb input files.

# Create the dataframe for upregulated.
tb_list <- c()
category <- c()
for (i in 1:length(up_list)){
  if (up_list[i] %in% tbbov_df$Mb_tag){
    tb_list <- c(tb_list, tbbov_df[tbbov_df$Mb_tag == up_list[i], "Rv_tag"])
    category <- c(category, tbbov_df[tbbov_df$Mb_tag == up_list[i], "category"])
  } else{
    tb_list <- c(tb_list, "not_mapped")
    category <- c(category, "not_mapped")
  }
}
commonup <- cbind(up_list, tb_list, category)
colnames(commonup) <- c("Mbovis", "Mtb", "GeneCategory")
# WARNING! MB3451C is not found and appended with empty row,so every row is move one position down. fix manually.
# Create the dataframe for downregulated.
tb_list <- c()
category <- c()
for (i in 1:length(down_list)){
  if (down_list[i] %in% tbbov_df$Mb_tag){
    tb_list <- c(tb_list, tbbov_df[tbbov_df$Mb_tag == down_list[i], "Rv_tag"])
    category <- c(category, tbbov_df[tbbov_df$Mb_tag == down_list[i], "category"])
  } else{
    tb_list <- c(tb_list, "not_mapped")
    category <- c(category, "not_mapped")
  }
}
commondown <- cbind(down_list, tb_list, category)
colnames(commondown) <- c("Mbovis", "Mtb", "GeneCategory")
# WARNING! MB3906 ans MB3906 not found and appended with empty row,so every row is move 2 position down. fix manually.

#write.csv(commonup, file = "results/BOVTB_commonup_RV.csv", quote = TRUE, row.names = FALSE, col.names = FALSE)
#write.csv(commondown, file = "results/BOVTB_commondown_RV.csv", quote = TRUE, row.names = FALSE, col.names = FALSE)

### 2. Make pie charts for gene categories.
data_up <- read.csv("results/BOVTB_commonup_RV.csv")
data_down <- read.csv("results/BOVTB_commondown_RV.csv")

# Make df for plotting.
up_df <- make_df_perc(data_up$GeneCategory)
down_df <- make_df_perc(data_down$GeneCategory)

# Summarize low frequent categories in "others" for upregulated genes.
up_plot_df <- up_df[1:7,]
up_others <- up_df[8:nrow(up_df),]
up_others <- c(sum(as.numeric(up_others$Counts)), "other", sum(as.numeric(up_others$Per)))
up_plot_df <- rbind(up_plot_df, up_others)
# Repeat for downregulated genes
down_plot_df <- down_df[1:7,]
down_others <- down_df[8:nrow(down_df),]
down_others <- c(sum(as.numeric(down_others$Counts)), "other", sum(as.numeric(down_others$Per)))
down_plot_df <- rbind(down_plot_df, down_others)

# Make piecharts.
plot_pie(up_plot_df)
plot_pie(down_plot_df)
