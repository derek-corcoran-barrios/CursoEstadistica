library(tidyverse)
##1Piratas y Cacas
Poop <- read_csv("Poop.csv")

summary(aov(time ~ type + cleaner + type:cleaner + Error(day), data = Poop))

##2Data ToothGrowth
data("ToothGrowth")
#1
summary(aov(len ~ supp + dose + supp:dose, data = ToothGrowth))
ggplot(ToothGrowth, aes(x = factor(dose), y = len)) + geom_boxplot(aes(fill = supp))+ theme_classic()

#3Que tipo de peliculas ganan mas 
Movies <- read_csv("Movies.csv")

summary(aov(revenue.inf ~ genre*creative.type*production.method, data = Movies))

#Como afecta el grupo taxonomico, nivel trófico y ciclo de actividad en el tamaño grupal

PanTHERIA <- read_csv("PanTHERIA.csv")

summary(aov(SocialGrpSize ~ Cycle*TrophicLevel*Order + Order/Family, data = PanTHERIA2))

##Actitud vs Genero Vs Frequencia



summary(aov(frequency ~ gender*attitude + Error(gender/subject*scenario), data = politeness_data))
