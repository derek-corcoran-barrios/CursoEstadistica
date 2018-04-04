##Datos educación en Chile

#leemos los datos
library(tidyverse)
EducacionChile <- read_csv("Practico2/EducacionChile.csv")

##Resumimos los datos usando tidyverse

EducacionChilePesada <- group_by(EducacionChile, Administration) %>% summarise(PromedioPSU = weighted.mean(Average.PSU, Number.of.records), SD.PSU = sd(Average.PSU), N = n())
EducacionChileNoPesada <- group_by(EducacionChile, Administration) %>% summarise(PromedioPSU = mean(Average.PSU), SD.PSU = sd(Average.PSU), N = n())

## Gráficamos usando ggplot2

ggplot(EducacionChile, aes(x = Administration, y = Average.PSU)) + geom_boxplot() + geom_jitter()

## Anova
set.seed(2018)
Muestra <- EducacionChile %>%  group_by(Administration) %>%  sample_n(size = 15)
Muestra.aov <- aov(Average.PSU ~ Administration, data = Muestra)
# Summary of the analysis
summary(Muestra.aov)

library(broom)
tidy(Muestra.aov)
glance(Muestra.aov)
augment(Muestra.aov)
