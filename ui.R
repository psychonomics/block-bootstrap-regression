
# [ToDo] Add a table for average model values, rather than 6 separate lines

# [ToDo] Add a direct link from documentation to dashboard

# http://stackoverflow.com/questions/37169039/direct-link-to-tabitem-with-r-shiny-dashboard
# http://blog.appsilondatascience.com/rstats/2016/12/08/shiny.router.html
# http://stackoverflow.com/questions/34315485/linking-to-a-tab-or-panel-of-a-shiny-app



#_______________________________________________________________________________
# chr.drive <-  "C:/Users/Tim/Dropbox"
# chr.project <- "0.Coding/DS10-Data-Products-John-Hopkins"
# chr.folder <- "4. Project/Block Bootstrap Regression"
# setwd(file.path(chr.drive, chr.project, chr.folder))


#_______________________________________________________________________________
library(shiny)
library(shinydashboard)



#_______________________________________________________________________________

# Header elements for the visualization
list.shiny.tag.header <- 
  dashboardHeader(title = "Block Bootstrap Regression using Grunfeld data", 
                  disable = FALSE)





  # Sidebar with a slider input for number of bins
  list.shiny.tag.sidebar <- 
    
    dashboardSidebar(
      
      sidebarMenu(
        menuItem(
          text = "Documentation",
          tabName = "documentation",
          icon = icon("tasks")
          ),
        
        menuItem(
          text = "Dashboard",
          tabName = "dashboard",
          icon = icon("industry")
          )
        ),
    
      
      #______________________________________  
      # Show if select dashboard
      
        selectInput('chr_chart', 
                    'Choose what to chart:',
                    c("model coefficients", "model fit")
                    ),
        
      
      #______________________________________  
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
  
        
        
      #______________________________________
      sliderInput("num.bootstrap.series",
                  "Number of bootstrap samples:",
                  min = 1,
                  max = 500,
                  value = 100),
  
      
      
      sliderInput("num.bootstrap.obs",
                  "Length of each sample:",
                  min = 20,
                  max = 200,
                  value = 50),
  
      
      
      
      sliderInput("num.block.length",
                  "Length of each block:",
                  min = 1,
                  max = 20,
                  value = 10)
  
      )
  
  
    
  # - - - - - - - - - - - - - - - - - -
  # Show a plot of the generated distribution
  
  list.shiny.tag.body <- 
    dashboardBody(
      tabItems(
        
        #____________________________________
        tabItem(
          tabName = "documentation",
          
          
          h3("Summary"),
          h4("This tool uses the Grunfeld (1950) Investment Data. This comprises annual data for 11 firms in the United States over 20 years, from 1935 to 1954. 
             The annual data for each firm is the gross investment, its value, and the capital stock of plant and equipment.  There are 220 observations."),
          
          
          h3("Technique"),
          h4("Linear regression is used to predict each firm's annual gross investment from its value and capital stock.  
             Block bootstrap is used to measure variance in the model coefficients.   
             The tool shows how the average model coefficients and fit vary with different bootstrap parameters."),
          
          h3("Menu Options"),
          h4("There are two drop down menus that control a single chart  
             The first offers a choice between variance in the model coefficients or variance in the model fit.  The second dropdown is conditional on the first, offering a choice of either predictor variables or summary fit measures."),
          h4("Three sliders control the bootstrap parameters.  The first is the number of blocked bootstrap samples to average over.  The second is the number of observations in each bootstrap sample, and the third is the number of observations in each bootstrap block."),
          h4("The chart visualises the values for each bootstrap sample. The mean, standard deviation and coefficient of variation are shown below the chart."),
          h4("Click the Dashboard icon to see the chart.  It may take a few seconds to load."),
          
          h3("References"),
          h4("More information about the block bootstrap can be found here"),
          tags$a(href = "https://en.wikipedia.org/wiki/Bootstrapping_(statistics)#Time_series:_Moving_block_bootstrap", "Wikipedia"),
          h4("More information about the Grunfeld data can be found here"),
          tags$a(href = "http://statsmodels.sourceforge.net/devel/datasets/generated/grunfeld.html", "SourceForge")
          ),
        
        
        #____________________________________
        tabItem(
          tabName = "dashboard",
      
          plotOutput("distPlot"),

          textOutput("chr.mean"),
          textOutput("chr.sd"),
          textOutput("chr.coeff.var")
                  
          # h5("Mean:"), 
          # textOutput("num.mean"),
          # 
          # h5("Standard deviation:"), 
          # textOutput("num.sd"),
          # 
          # h5("Coefficient of Variation:"), 
          # textOutput("num.coeff.var")
            
          )
        )
      )
      
  



  dashboardPage(header = list.shiny.tag.header, 
                sidebar = list.shiny.tag.sidebar, 
                body = list.shiny.tag.body, 
                skin = "green")
