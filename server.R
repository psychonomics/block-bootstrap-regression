

#_______________________________________________________________________________
# [Source] Functions for boot strap regression
source("functions.R", chdir = TRUE)

#_______________________________________________________________________________
data(Grunfeld)
# View(Grunfeld)
# str(Grunfeld)


#_______________________________________________________________________________
# [Define] shinyServer ----
shinyServer(function(input, output) {

  
  #- - - - - - - - - - - - - - - - - -
  # renderPlot ----
  output$distPlot <- renderPlot({

    # chr.predictor <- "intercept"
    # chr.fit <- "AIC"

    # num.bootstrap.series <- 1000
    # num.bootstrap.obs <- 200
    # num.block.length <- round(num.bootstrap.obs^(1/3) * 2, 0)


    chr_chart <- input$chr_chart
    chr.predictor <- input$chr.predictor
    chr.fit <- input$chr.fit

    num.bootstrap.series <- input$num.bootstrap.series
    num.bootstrap.obs <- input$num.bootstrap.obs
    num.block.length <- input$num.block.length

    num.predictor <- grep(chr.predictor, c("intercept", "value", "capital"))
    num.fit <- grep(chr.fit, c("adj.r.squared", "AIC", "deviance"))

    
    #- - - - - - - - - - - - - - - - - - 
    # [Bootstrap] multiple sample observations ----
    list.boot.obs <-
      fn.block.bootstrap.obs(df.data = Grunfeld,
                             num.bootstrap.series = num.bootstrap.series,
                             num.obs = num.bootstrap.obs,
                             num.block.length = num.block.length)

    # [Define] Linear regression formula
    formula.lm <- 
      reformulate(termlabels = c('value', 'capital'), response = 'invest')
    
    # [Estimate] multiple models (sample observations)
    list.boot.lm <-
      list.boot.obs %>% 
      purrr::map(lm, formula = formula.lm)


    #- - - - - - - - - - - - - - - - - -
    # [Summarise] model fit ----
    list.boot.lm.glance <-
      purrr::map(list.boot.lm, broom::glance)

    df.glance <-
      fn.broom.glance(list.boot.lm.glance = list.boot.lm.glance,
                      num.bootstrap.series = num.bootstrap.series)



    df.glance.summary <- fn.distribution.summary(df.glance)


    #- - - - - - - - - - - - - - - - - -
    chr.main.title <-
      paste0("Model fit variation using ", chr.fit)


    if (chr_chart == "model fit") {
      # draw the histogram with the specified number of bins
      hist(df.glance[[chr.fit]],
           col = 'darkgray', border = 'white',
           main = chr.main.title,
           xlab = chr.fit
           )
      
      # Decide on decimal places, based on variable being plotted
      if (abs(df.glance.summary$mean[num.fit]) > 10) {
        num.round.by <- 0
        } else {
        num.round.by <- 2
        }
       
      output$num.mean <- 
        renderText({
          round(df.glance.summary$mean[num.fit], num.round.by)
          })
      
      output$num.sd <- 
        renderText({
          round(df.glance.summary$sd[num.fit], num.round.by)
          })
      
      output$num.coeff.var <- 
        renderText({
          round(df.glance.summary$sd[num.fit] / 
                  df.glance.summary$mean[num.fit], 2)
          })
          
      
      }


    #- - - - - - - - - - - - - - - - - -
    # [Summarise] model coefficients ----
    list.boot.lm.tidy <-
      purrr::map(list.boot.lm, broom::tidy)

    df.tidy <-
      fn.broom.tidy(list.boot.lm.tidy = list.boot.lm.tidy,
                    num.bootstrap.series = num.bootstrap.series)

    df.tidy.summary <- fn.distribution.summary(df.tidy)


    chr.main.title <-
      paste0("Coefficient variation for ", chr.predictor)


    if (chr_chart == "model coefficients"){
      # draw the histogram with the specified number of bins
      hist(df.tidy[[chr.predictor]],
           col = 'darkgray', border = 'white',
           main = chr.main.title,
           xlab = chr.predictor
           )
      
      # Decide on decimal places, based on variable being plotted
      if (abs(df.tidy.summary$mean[num.predictor]) > 10) {
        num.round.by <- 0
        } else {
        num.round.by <- 2
        }

      output$num.mean <- 
        renderText({
          round(df.tidy.summary$mean[num.predictor], num.round.by)
          })
      
      output$num.sd <- 
        renderText({
          round(df.tidy.summary$sd[num.predictor], num.round.by)
          })
      
      output$num.coeff.var <- 
        renderText({
          round(df.tidy.summary$sd[num.predictor] / 
                  df.tidy.summary$mean[num.predictor], 2)
          })
    
      }
  
    })

  })
