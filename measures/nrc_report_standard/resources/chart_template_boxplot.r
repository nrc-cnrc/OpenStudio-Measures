# R script to create a simple boxplot image.

# Get datafile and output image file names from the command line.
args = commandArgs(trailingOnly=TRUE)
input = args[1]
output = args[2]

# Load required libraries. Our default docker image has the packages already installed.
library(ggplot2)
library(tidyr)

# Read the input file and convert to a long data frame
setpoint <- read.csv(file=input)
long_df <- setpoint %>% gather(Key, Value)

figure <- ggplot(long_df, aes(x=Value, y=Key)) +
          geom_boxplot()

png(output)
print(figure)
dev.off()