#Pipeline: from reading the table to perform statistical analysis
#Make sure that your table is in your working directory folder

#Read the data table with the information

#For .txt tables
my_data=read.table("Table.txt",sep = "\t", head=T)

#For .csv tables
my_data=read.csv("Table",sep = "\t", head=T)

#Analysis of the statistical assumptions

#Install the necessary packages and load the corresponding libraries

install.packages("dplyr")
library("dplyr")

install.packages("ggpubr")
library("ggpubr")

install.packages("car")
library("car")

#Random sampling of the data to check 

set.seed(1234)
dplyr::sample_n(my_data, 10)

#From now on, RV is the Response Variable of interest 
#From now on, "Fn"  (n=1,2,3,...) are the factors of study
#For the created objects (anova <-aov...) the summary(object) command is used to check the table
#p-values under 0.05 mean that the effect is significative for that factor

#Assumption of normal distribution of the data

#Visual inspection of the data distribution

ggdensity(my_data$RV,
          main = "Density plot of RV",
          xlab = "RV")
#Approximately normal data has a Gaussian distribution

#Visual inspection of the residues (QQ plot)

ggqqplot(my_data$RV)
#Approximately normal data has residues close to the linear tendency line

#Statistical test for normality: Shapiro-Wilk's test

shapiro.test(my_data$VR)
#Approximately normal data sets have p-values over 0.05

#Assumption of homogeneous variances for the levels (homocedasticity)

#Statistical test must be carried for each factor of interest
#This includes the interactions when there is more than one way for the ANOVA

leveneTest(RV ~ Fn, my_data)
#Homocedastic data sets have p-values over 0.05

#############################################################################################################

#Student's t-test
#Only one source of variance with only two levels
#Needs an approximately normal distribution and homogeneous variances

#Student's t-test: comparison with a theoretical mean
#First of all, data must be transformed to numeric vectors

x=my_data$Source
#Source is the header of the data 
#To test the data's mean against a theoretical (known) mean

t_test_1 <-t.test(x, mu=n)
#mu is the theoretical mean and n is it's numeric value
#p-value under 0.05 means that the two means are different

#Student's t-test: comparison between two means
#First of all, data must be transformed to numeric vectors

x=my_data$Source1
y=my_data$Source2
#Sources are the headers of the data
#To test the two means 

t_test_2 <-t.test(x,y)
#p-value under 0.05 means that the two means are different

#After the t test, the following commands must also be used

#p-value 
res$p.value 

#degrees of freedom
test$parameter 

#t statistic value
test$statistic

#############################################################################################################

#ANOVA analysis and variations

#All the ANOVA commands have the structure "aov(lm(RV~Fn, my_data))" 
#aov is the command to perform the ANOVA
#lm is the linear model fit
#Fn represents the sources of variance
#Sources of variance depend on the ANOVA type
#IMPORTANT: R assumes that the factors are FIXED
#p-values under 0.05 mean that the source of variance has a significant effect on the RV
#Homocedastic data is a must for carrying out ANOVA analysis
#However, ANOVA is robust to deviations of the normality assumption (3 or more replicates)


#1-way ANOVA (only one factor of interest, 2 or more levels possible)

one_way_anova <-aov(lm(RV~F1, my_data))

#2-way ANOVA (2 factors of interest, 2 or more levels possible per factor)
#From 2-ways onward, it's possible to evaluate the interactions between factors

#If the interaction is not of interest
two_way_anova <-aov(lm(RV~F1+F2, my_data))
#Both, none, or only one factor can be statistically significative


#If the interaction is of interest
two_way_anova <-aov(lm(RV~F1*F2, my_data))
#Both, none, only one factor or the interaction can be statistically significative
#An statistically significative interactions means that the factors' effects not independent

#Keep in mind for ANOVAS of three or more ways
#Interaction is of interest: put "*" between factors
#Interaction is not of interest: put "+" between factors

#For all ANOVAs of two or more ways: 
#If the interaction is significative, it's not possible to interpretate the effect of each individual factor
#The interaction should be the first thing to be looked at when doing this type of analysis


#Nested ANOVAs: factors inside factors

#Depending on the data type, R may have trouble reading the sources of variance
#To solve this, the sources of variance are converted to readable factors

my_data$F1 = as.factor(my_data$F1)
#This is carried for every factor of interest

#In the ANOVA command, factors are nested writing "%in%" between them
#If there are three factors (F3 in F2 in F1), the commands is written as:
 
nested_anova <-aov(lm(VR~F1+F2%in%F1, my_data))

#The replicas are contained in F3
#These degrees of freedom are the same as the error's degrees of freedom
#If said factor is included in the command, it won't be read as the error
#IF this happens, R can't perform the statistical analysis

#Block ANOVA

#Block designs are used when the experimental settings create a gradient
#Examples: plants in a room with a light gradient (close and far from a window)
#These desgins "block" the effect of the gradient by setting the samples across it
#The block is ALWAYS a random factor 

#1) Block designs without replication
#This is used when there are no replicas INSIDE the block
#This does not account for the total number of experimental units of a certain level
#In this type of designs, the error's DF are the Factor x Block interaction's DF

block_no_r <-aov(lm(RV~Block+F1+Error(Block:F1), my_data))
#Since there is no replication, you can only evaluate the effect of the Factor
#IMPORTANT: R doesn't recognize this and calculates an F value for the blocks
#This should be ignored and modified in the table when used after it's obtained

#2) Block designs with replication
#This is used when there are no replicas INSIDE the block
#This does not account for the total number of experimental units of a certain level
#In this type of designs, it works as a Two-Way ANOVA

block_r <-aov(lm(RV~Block*F1, my_data))
#With replication, it is possible to also test the effects of the block and the interaction

#Split-plot ANOVA

#Split-plot designs are recognized as having two or more factors and a block
#These factors are apllied to different sizes of experimental units 
#The block is what separates said experimental unit sizes
#One or more factors are apllied to all the blocks (called "Main plot")
#One or more factors are applied to the units INSIDE the blocks (called "Sub plot")

#Split-plot without replication
split_plot <- aov(RV~Main_Plot_F*Sub_Plot_F+Error(block/Main_Plot_F), my_data)


#Repeated Measures ANOVA (RM-ANOVA)

#RM-ANOVA structure works in the same way as a Split-Plot ANOVA
#The main difference is that the Sub plot factor is a measure over time
#For this analysis, the blocks are the experimental units wich are measured at different times
#The Main plot is called "Between subjects" and the subplot is called "Within subjects"
#RM-ANOVA CAN'T HAVE REPLICATES, as it is impossible to replicate the same exact moment 

RM-ANOVA <- aov(RV~Between_F*Time_F+Error(block/Between_F), my_data)

#Depending on how the time effects structure is, some alternatives to the RM-ANOVA can be used
#If across time, the different levels of the "Between factor" a similar tendency (no interaction), averaging is possible and treat it as a one way ANOVA
#This approach assumes that there is no variaton within the experimental units
#If the time measures are taken from different experimental units, there are no blocks and the effect of time is treated as a two-way ANOVA
 
#MANOVA (multivariate analysis of variance)

#MANOVA tests are used when you want to analyze how one or more factors affect multiple response variables
#For this, instead of "aov", the "manova" command is used:

manova <- manova(cbind(RV1, RV2, ..., RVn) ~ F, my_data)
#To get the summary for each Response, use the following command

summary.aov(manova)
#This shows if the selected factor has an effect on each response

#It is also possible to make a MANOVA with two or more ways
two_manova <- manova(cbind(RV1, RV2, ..., RVn) ~ F1*F2, my_data)

summary.aov(two_manova)
#This shows if each factor and the interactoin between them has a significant effect on the responses

#############################################################################################################

#Tukey's posteriori test

#Create the object to where Tukey's test will be applied
tukey_func <- TukeyHSD(anova_object)

#Choose to which source of variance you apply the test
#This is done only if said source of variance has more than 2 levels

tukey_func$`F`

#`F` can be an individual factor as well as an interaction
#Analysis of the interaction can also inform differences between the levels of the interacting factors
#IMPORTANT: Tukey's test has low power and low control of error rates 
#This can lead to results that not correlate with the ANOVA

#Create the table that contains the test results

#For .txt tables
write.table(tukey_func$`F`,file="Tukey_factor.txt")

#For .csv tables

write.csv(tukey_func$`F`,file="Tukey_factor.csv")

