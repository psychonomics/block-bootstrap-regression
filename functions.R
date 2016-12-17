#_______________________________________________________________________________
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(AER)
library(tseries)




#_______________________________________________________________________________
# Block bootstrap observations----
# [ToDo] Replace for loop with a mapped function (or lapply) 
fn.block.bootstrap.obs <-
  function(df.data, num.bootstrap.series, num.obs, num.block.length) {
    
    # [Default] Bootstrap parameters
    # num.obs <- nrow(df.data)
    # num.block.length <- round(num.obs^(1/3) * 2, 0)
    
    num.idx.obs <- 1 : num.obs
    
    
    # Extract bootstrapped row indices, one new series for each bootstrap sample
    df.boot.idx <-
      as.data.frame(
        tseries::tsbootstrap(
          x = num.idx.obs,
          statistic = NULL,
          m = 1, b = num.block.length,
          type = "block", nb = num.bootstrap.series
          )
        )
    
    names(df.boot.idx) <- 
      paste0("sample_", 1 : num.bootstrap.series)
    
    # Here are the individual bootstrapped series
    class(df.boot.idx)
    dim(df.boot.idx)
    
    
    # Extract actual dataframes, one for each sample block
    list.boot.obs <- list()
    
    for (i in 1 : num.bootstrap.series) {
      num.boot.idx <- df.boot.idx[[i]]
      list.boot.obs[[i]] <- df.data[num.boot.idx, ]
      }
    
    names(list.boot.obs) <- names(df.boot.idx)
    # str(head(list.boot.obs))
    
    return(list.boot.obs)
    
  }

#_______________________________________________________________________________
# [Function] Multiple regression  ----
# [ToDo] Generalise to accept variables, as well as data 
fn.lm.Grunfeld <- function(formula.lm, df.data) {
  list.lm <- lm(formula = formula.lm, data = df.data)
  return(list.lm)
  }

#_______________________________________________________________________________
# [Function] Extract fit statistics ----
# [ToDo] Replace for loop with a mapped function
# [ToDo] Generalise to accept summary statistics as input
fn.broom.glance <- function(list.boot.lm.glance, num.bootstrap.series) {
  
  chr.glance.extract <- c("adj.r.squared", "AIC", "deviance")
  
  df.glance <-
    data.frame(matrix(NA, nrow = num.bootstrap.series,
                      ncol = length(chr.glance.extract)))
  names(df.glance) <- chr.glance.extract
  
  for (int.idx in 1 : num.bootstrap.series) {
    df.glance[int.idx, ] <-
      list.boot.lm.glance[[int.idx]][ , chr.glance.extract]
    }
  
  return(df.glance)
  }

#_______________________________________________________________________________
# [Function] Extract predictor coefficients ----
# [ToDo] Replace for loop with a mapped function
# [ToDo] Generalise to accept variables as input
fn.broom.tidy <- function(list.boot.lm.tidy, num.bootstrap.series) {
  
  chr.tidy.extract <- c("intercept", "value", "capital")
  
  df.tidy <-
    data.frame(matrix(NA, nrow = num.bootstrap.series,
                      ncol = length(chr.tidy.extract)))
  
  names(df.tidy) <- chr.tidy.extract
  
  for (int.idx in 1 : num.bootstrap.series) {
    df.tidy[int.idx, ] <-
      list.boot.lm.tidy[[int.idx]] %>%
      dplyr::select(-(std.error:p.value)) %>%
      tidyr::spread(term, estimate)
    }
  
  return(df.tidy)
  
  }



#_______________________________________________________________________________
# [Function] Summarise bootstrap distribution ----
# [ToDo] Generalise the sapply statement for each summary function
fn.distribution.summary <- function(df.data) {
  
  # df.data <- df.glance
  chr.names <- names(df.data)
  chr.summary <- c("mean", "median", "sd", "percentile.5", "percentile.95")
  
  df.distribution.summary <-
    data.frame(matrix(NA, nrow = length(chr.names), ncol = 1 + length(chr.summary)))
  names(df.distribution.summary) <- c("metric", chr.summary)
  
  df.distribution.summary$metric <- chr.names
  
  df.distribution.summary$mean <- sapply(df.data, mean)
  df.distribution.summary$median <- sapply(df.data, median)
  df.distribution.summary$sd <- sapply(df.data, sd)
  df.distribution.summary$percentile.5 <- sapply(df.data, quantile, 0.05)
  df.distribution.summary$percentile.95 <- sapply(df.data, quantile, 0.95)
  
  return(df.distribution.summary)
  }
#-------------------------------------------------------------------------------
