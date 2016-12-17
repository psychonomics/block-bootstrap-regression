

#_______________________________________________________________________________
# chr.drive <-  "C:/Users/Tim/Dropbox"
# chr.project <- "0.Coding/DS10-Data-Products-John-Hopkins"
# chr.folder <- "4. Project/Block Bootstrap Regression"
# setwd(file.path(chr.drive, chr.project, chr.folder))


#_______________________________________________________________________________
library(shiny)
library(shinydashboard)



#_______________________________________________________________________________
shinyUI(fluidPage(

  # Application title
  titlePanel("Block Bootstrap Regression using Grunfeld dataset"),

  
  # Sidebar with a slider input for number of bins
  sidebarLayout(

    
    
    # - - - - - - - - - - - - - - - - - -
    sidebarPanel(

      
      
      selectInput('chr_chart', 'Choose what to chart:',
                  c("model coefficients", "model fit")),

      
      
      # Show if select coefficients
      conditionalPanel(
        condition = "input.chr_chart == 'model coefficients'",
        selectInput('chr.predictor', 'Choose a variable:',
                    c("intercept", "value", "capital"))
      ),

      
      
      # Show if select model fit
      conditionalPanel(
        condition = "input.chr_chart == 'model fit'",
        selectInput('chr.fit', 'Choose a measure of fit:',
                    c("adj.r.squared", "AIC", "deviance"))
      ),

      
      
      sliderInput("num.bootstrap.series",
                  "Number of blocked bootstrap samples to average over:",
                  min = 1,
                  max = 500,
                  value = 100),

      
      
      sliderInput("num.bootstrap.obs",
                  "Number of observations in each bootstrap sample:",
                  min = 50,
                  max = 200,
                  value = 70),

      
      
      
      sliderInput("num.block.length",
                  "Number of observations in each bootstrap sample block:",
                  min = 1,
                  max = 50,
                  value = 12)

    ),


    
    # - - - - - - - - - - - - - - - - - -
    # Show a plot of the generated distribution
    mainPanel(
      
      plotOutput("distPlot"),
      
      h5("Mean:"), 
      textOutput("num.mean"),
      
      h5("Standard deviation:"), 
      textOutput("num.sd"),

      h5("Coefficient of Variation:"), 
      textOutput("num.coeff.var")
      
          
      )
    
    

  )
))
