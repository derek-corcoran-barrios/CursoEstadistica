#leer datos
iris <- read.csv("~/Documents/BioestadisticaII/iris.csv")
#Histograma de largo de petalo de la primera especie 
hist(iris$Petal.Length[1:50])

library(tidyverse)
library(dplyr)
library(readxl)
#Para resumir medi a y desviacion estandard
DF <- group_by(iris, Species) %>% summarise_all(funs(mean, sd))


Versicolor <- filter(iris, Species != "versicolor" & Petal.Length > 1.2) %>% group_by(Species) %>% summarise_all(mean) %>% select(Species, contains("Petal"))

write.csv(DF, "Tabla1.csv")