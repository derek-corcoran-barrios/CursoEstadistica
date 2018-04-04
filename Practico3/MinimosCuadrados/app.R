#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

data("mtcars")
library(shiny)
library(tidyverse)
library(broom)
library(pwr2)
Metric <- mtcars
data("iris")
Metric$mpg <- Metric$mpg * 0.425144
Metric$wt <- Metric$wt  * 0.453592
Metric$Prediction <- NA
Metric$Cuadrados <- NA


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Estimación de parametros basado en mínimos cuadrados"),
   tabsetPanel(
   # Sidebar with a slider input for number of bins 
  tabPanel("Regresión",
   sidebarLayout(
      sidebarPanel(
        h3("Estimación de pendiente e intercepto"),
        p("En una regresión lineal, la pendiente es... "),
         sliderInput("pendiente",
                     "Estimación de la pendiente:",
                     min = -10,
                     max = 10,
                     value = 0),
         sliderInput("intercepto",
                     "Estimación del intercepto:",
                     min = 5,
                     max = 20,
                     value = 8),
         checkboxInput("resid", label = "Mostrar residuales", value = FALSE),
         checkboxInput("checkbox", label = "Mostrar solución", value = FALSE)
         
         
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot"),
         verbatimTextOutput("Cuadrados"),
         verbatimTextOutput("Solucion"), 
         p("Desarrollado por Giorgia Graells y Derek Corcoran")
      )
   )),#"Cierre primer tabpanel"
  tabPanel("ANOVA",
           sidebarLayout(
             sidebarPanel(
               h3("ANOVA"),
               sliderInput("muestra",
                           "Número de instituciones muestreadas:",
                           min = 3, max = 50, value = 10),
               radioButtons("radio", label = "Tipo de error",
                            choices = list("Totales" = 1, "Variable" = 2, "Error" = 3),selected = 1)),
             mainPanel(
               plotOutput("ANOVAout"),
               tableOutput("ANOVAtable"),
               tableOutput("Test")
              )
             )
           ),#Cierre segundo tabpanel
  #Inicio tercer tabpanel
  tabPanel("Calculo de poder",
           sidebarLayout(
             sidebarPanel(
           sliderInput("K",
                       "Número de grupos a testear:",
                       min = 3, max = 10, value = 5),
           sliderInput("alpha",
                       "Alpha:",
                       min = 0.01, max = 0.99, value = 0.05)
           ,
           sliderInput("poder",
                       "Poder deseado:",
                       min = 0.01, max = 0.99, value = 0.9),
           numericInput("SD", 
                        "Desviación estandar de la muestra:", 0.4, min = 0, max = 1000000)
           ,
           numericInput("Efecto", 
                        "Diferencia mínima a detectar:", 0.5, min = 0, max = 1000000)), 
           mainPanel(plotOutput("PowerPlot"),
                     verbatimTextOutput("PowerPrint")))
  )
   )#Cierre de tabset panel
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      Metric$Prediction <- input$intercepto + input$pendiente*Metric$wt
      Metric$Cuadrados <- (Metric$mpg - Metric$Prediction)^2
      # draw the histogram with the specified number of bins
      G <- ggplot(Metric, aes(x = wt, y = mpg)) + geom_point() + geom_abline(slope = input$pendiente, intercept = input$intercepto, color = "red", lty = 2) + theme_classic() + xlab("Peso [Toneladas]") + ylab("Rendimiento [Km/L]")
      if (input$checkbox == TRUE){
      G <- G + geom_smooth(method = "lm")  
      }
      if (input$resid == TRUE){
        G <- G + geom_segment(aes(xend = wt, yend = Prediction))
      }
      G
   })
   
   
   output$Cuadrados <- renderPrint({
     Metric$Prediction <- input$intercepto + input$pendiente*Metric$wt
     Metric$Cuadrados <- (Metric$mpg - Metric$Prediction)^2
     SumSquares <- sum(Metric$Cuadrados)
     print(paste("La suma de Cuadrados es", round(SumSquares,3)))
   })
   output$Solucion <- renderText({
     Modelo <- tidy(lm(mpg~wt, data = Metric))
     Metric$Prediction <- Modelo$estimate[1] + Modelo$estimate[2]*Metric$wt
     Metric$Cuadrados <- (Metric$mpg - Metric$Prediction)^2
     SumSquares <- sum(Metric$Cuadrados)
     a <- paste("La pendiente es", round(Modelo$estimate[2], 2), "el intercepto es", round(Modelo$estimate[1], 2), "y la suma de cuadrados es", round(SumSquares, 2))
     if (input$checkbox == TRUE){
       print(a)
     }
   })
#################Anova
     IrisMuestra <- reactive({
       iris %>% group_by(Species) %>% sample_n(size = input$muestra) %>% mutate(Media.Grupo = mean(Sepal.Length))
     })
     output$ANOVAout <- renderPlot({
       G <- ggplot(IrisMuestra(), aes(x = Species, y = Sepal.Length)) + geom_boxplot() +  geom_point(position = position_jitter(height = 0L, seed = 1L), aes(color = Species)) + theme_classic()
       if (input$radio == 1){
         G <- G + geom_hline(aes(yintercept=mean(Sepal.Length))) + geom_linerange(aes(x=Species, ymax=Sepal.Length, ymin=mean(Sepal.Length)),position = position_jitter(height = 0L, seed = 1L))
       }
       
       if (input$radio == 3){
         G <- G  + stat_summary(fun.y=mean, aes(ymin=..y.., ymax=..y.., color = Species), geom='errorbar') + geom_linerange(aes(x=Species, ymax=Sepal.Length, ymin=Media.Grupo),position = position_jitter(height = 0L, seed = 1L))
       }
       
       if (input$radio == 2){
         G <- G  + stat_summary(fun.y=mean, aes(ymin=..y.., ymax=..y.., color = Species), geom='errorbar') + geom_hline(aes(yintercept=mean(Sepal.Length)))+ geom_linerange(aes(x=Species, ymax=mean(Sepal.Length), ymin=Media.Grupo),position = position_jitter(height = 0L, seed = 1L))
       }
       
       G
     })
     output$ANOVAtable <- renderTable({
       IrisMuestra <- IrisMuestra()
       IrisMuestra$Cuadrados <- (IrisMuestra$Sepal.Length - mean(IrisMuestra$Sepal.Length))^2
       IrisMuestra$Residuales <- (IrisMuestra$Sepal.Length - IrisMuestra$Media.Grupo)^2 
       IrisVariable <- IrisMuestra %>%  group_by(Species) %>% summarise(Media = mean(Sepal.Length), n = n()) %>% mutate(cuadrados = n*(Media -  mean(IrisMuestra$Sepal.Length))^2)
       TablaANOVA <- data.frame(CuadradosTotales = sum(IrisMuestra$Cuadrados), CudradosVariable = sum(IrisVariable$cuadrados), CuadradosResiduales = sum(IrisMuestra$Residuales))
     })
     output$Test <- renderTable({
       broom::tidy(aov(Sepal.Length ~ Species, data = IrisMuestra()))
     })
     output$PowerPlot <- renderPlot({
       x <- 0
       n <- 2
       power <- list()
       while(x < input$poder) {
         power[[n]] <- broom::tidy(pwr.1way(k=input$K, n=n, alpha=input$alpha, delta=input$Efecto, sigma=input$SD))
         x <- broom::tidy(pwr.1way(k=input$K, n=n, alpha=input$alpha, delta=input$Efecto, sigma=input$SD))$power
         n <- n+1
         if (n == 300){
           break
         }
       }
       
       power <- do.call(rbind, power)
       
       ggplot(power, aes(x = n, y = power)) + geom_line() + ylim(0,1) + theme_classic() + ylab("Poder")
       
     })
     
     output$PowerPrint <- renderPrint({
       x <- 0
       n <- 2
       power <- list()
       while(x < input$poder) {
         power[[n]] <- broom::tidy(pwr.1way(k=input$K, n=n, alpha=input$alpha, delta=input$Efecto, sigma=input$SD))
         x <- broom::tidy(pwr.1way(k=input$K, n=n, alpha=input$alpha, delta=input$Efecto, sigma=input$SD))$power
         n <- n+1
         message(n)
         if (n == 300){
           break
         }
       }
       
       power <- do.call(rbind, power)
       paste("La muestra necesaria para el estudio es: ", power$n[nrow(power)], "y el poder es", round(power$power[nrow(power)],4))
     })
}

# Run the application 
shinyApp(ui = ui, server = server)

