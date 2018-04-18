#Understanding ANOVA
library(tidyverse)
library(broom)
library(lme4)


data("CO2")
#Subespecie y tratamiento efectos fijos plnata efecto aleatorio
ggplot(CO2, aes(x = Plant, y = uptake)) + geom_boxplot() + geom_vline(xintercept = c(3.5, 9.5), lty = 2) + geom_vline(xintercept = 6.5, lty = 2, color = "red")

aov(uptake  ~  Type + Treatment + Type:Treatment + Type/Plant, data=CO2)
summary(aov(uptake  ~  Type + Treatment + Type:Treatment, data=CO2))

