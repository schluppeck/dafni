# turn blockorder file into a 3 column text file for FSL
#
# NB! this code requires a recent version of dplyr.
#     may need to install via:
#     
#   devtools::install_github("tidyverse/dplyr@rc_0.8.0")
#
# TODO: turn this into a programming exercise in matlab?!
#
# ds 2019-02



library(tidyverse)
library(readr)

# some params
TR <- 1.5; #s
blockLength <- 12;
initiHalfCycle  <-TRUE;
orderFile <-  "blockorder.txt"

# calculate offset in [s] (if needed)
offset <- if_else(initiHalfCycle, TR*blockLength/2, 0)

d <- read_table(orderFile, col_names = FALSE) %>% 
  rename(category = X1) %>% 
  mutate(startTime = TR*blockLength*(row_number()-1) + offset,
         duration = TR*blockLength/2, 
         level = 1)

# https://stackoverflow.com/questions/33775239/emulate-split-with-dplyr-group-by-return-a-list-of-data-frames
grps <- d %>% group_by(category) %>% group_split()

# make a function that writes a delimited file based on 
write_fsl_3col_format <- function(df){
  filename <- paste0(first(df$category), '.txt')
  df %>% 
    select(startTime, duration, level) %>% 
    write_delim(filename, col_names = FALSE)
}

# process all three groups with map/walk
walk(grps, write_fsl_3col_format)

