#Understanding ANOVA
library(tidyverse)
library(broom)
library(lme4)


data("CO2")
#Subespecie y tratamiento efectos fijos plnata efecto aleatorio
ggplot(CO2, aes(x = Plant, y = uptake)) + geom_boxplot() + geom_vline(xintercept = c(3.5, 9.5), lty = 2) + geom_vline(xintercept = 6.5, lty = 2, color = "red")

summary(lmer(uptake  ~  Type + Treatment + Type:Treatment + conc + (1|Plant), data=CO2))


anova(lmer(uptake  ~  Type + Treatment + Type:Treatment + (1|Plant), data=CO2))

summary(lmer(uptake  ~ Treatment + Type:Treatment+ (1|Type) + (1|Plant), data=CO2))

coef(lmer(uptake  ~  Type + Treatment + Type:Treatment + (1|Plant), data=CO2))

fit2 <- lmer(uptake  ~  Type + Treatment + Type:Treatment + conc + (1|Plant), data=CO2)
fit3 <- lmer(uptake  ~ Treatment + Type:Treatment+ (1|Type) + (1|Plant), data=CO2)

library(sjPlot)
sjp.lmer(fit2, type = "eff")
sjp.lmer(fit2)
plot_model(fit2, type = "pred", terms = c("Treatment", "Type"))
plot_model(fit3, type = "pred", terms = c("Treatment", "Type"))
plot_model(fit2, type = "eff", terms = c("Treatment", "Type"))

anova(fit2, fit3)


aov(uptake  ~  Type + Treatment + Type:Treatment + Type/Plant, data=CO2)
summary(aov(uptake  ~  Type + Treatment + Type:Treatment + Error(Type/Plant), data=CO2))
summary(aov(uptake  ~  Type + Treatment + Type:Treatment, data=CO2))

