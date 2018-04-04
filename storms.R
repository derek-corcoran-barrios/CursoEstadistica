library(tidyverse)
data("storms")

Hu <- filter(storms, status == "hurricane") %>% group_by(year) %>% summarise(Wind = mean(wind), Diameter = mean(hu_diameter))
