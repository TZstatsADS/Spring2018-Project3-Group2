### Train a classification model with training images

## GBM
gbm_train<- function(dat_train, label_train, par=NULL){
  library("gbm")
  if(is.null(par)){
    depth <- 7
  } else {
    depth <- par$depth
  }
  fit_gbm <- gbm.fit(x=data.frame(dat_train), y=label_train,
                     n.trees=800,
                     distribution="multinomial",
                     interaction.depth=depth, 
                     bag.fraction = 0.5,
                     verbose=FALSE)
  best_iter <- gbm.perf(fit_gbm, method="OOB", plot.it = FALSE)
  
  return(list(fit=fit_gbm, iter=best_iter))
}


source("../lib/CV.R")
gbm_para <- function(dat_train, label_train, model_values, run.cv){
  if(run.cv){
    err_cv <- array(dim=c(length(model_values), 2))
    for(k in 1:length(model_values)){
      cat("k=", k, "\n")
      err_cv[k,] <- cv_gbm(dat_train, factor(label_train$label), model_values[k], K)
    }
    save(err_cv, file="../output/err_gbm_cv.RData")
  }

  model_best = model_values[1]
  model_best <- model_values[which.min(err_cv[,1])]
  par_best <- list(depth=model_best)
  return(par_best)
}

## XGBoost
xgb_train <- function(dat_train, label_train) {
library(xgboost)
best_para<-list(max_depth = 3, eta = 0.3, nrounds = 150, gamma = 0,
                nthread = 2, subsample = 0.5,
                objective = "multi:softprob", num_class = 3)
xgbst.train <- xgb.DMatrix(data = data.matrix(dat_train), label = label_train[ ,3] - 1)
fit_xgb <- xgboost(data = xgbst.train, params = best_para, 
                      nrounds = best_para$nrounds, verbose = 0)
  return(fit_xgb)
}

# Tuning parameters "maximum depth" & "eta (shrinkage)" using cross-validation
xgb_para <- function(dat_train,label_train,K,nround) {
  dtrain <-  xgb.DMatrix(data=data.matrix(dat_train),label=label_train)
  max_depth<-c(2, 3, 4, 5)
  eta<-c(0.1, 0.2, 0.3, 0.4, 0.5)
  evaluation_dat <- NULL
  best_params <- list()
  best_err <- Inf 
  for (i in 1:length(max_depth)) {
    for (j in 1:length(eta)) {
      my.params <- list(max_depth = max_depth[i], eta = eta[j], nrounds=nround)
      set.seed(10)
      cv.output <- xgb.cv(data = dtrain, max_depth = my.params$max_depth, 
                          eta = my.params$eta, gamma = 0, subsample = 0.5, nrounds = nround, 
                          objective = "multi:softprob", num_class = 3,
                          nfold = K, nthread = 2, metrics = "merror", verbose = 0)
      
      if (is.null(evaluation_dat) == FALSE) {
        p <- paste0("max_depth=",max_depth[i],", eta=", eta[j])
        eva <- cv.output$evaluation_log[ ,c(1,4,5)]
        eva$parameter <- p
        evaluation_dat <- rbind(evaluation_dat, eva)
      } else {
        p <- paste0("max_depth=",max_depth[i],", eta=", eta[j])
        evaluation_dat <- cv.output$evaluation_log[ ,c(1,4,5)]
        evaluation_dat$parameter <- p
      }
      min_err <- mean(cv.output$evaluation_log$test_merror_mean)
      print(min_err)
      
      if (min_err < best_err){
        best_params <- my.params
        best_err <- min_err
      }
    }
  }
  return(list(evaluation_dat, best_params, best_err))
}

# Tuninng parameter "nrounds (M)" using cross-validation
xgb.set.M <- function(dat_train, label_tain, M.range = c(100, 280), max_depth=3, eta=0.3, step = 10, K = 5) {
  nround <- seq(M.range[1], M.range[2], by = step)
  best_err <- Inf 
  best_M <- NA
  
  for (i in 1:length(nround)) {
    set.seed(10)
    cv.output <- xgb_cv(data.train = dat_train, label.train = label_train ,max_depth = max_depth, 
                        eta = eta, gamma = 0, subsample = 0.5, nrounds = nround[i],
                        objective = "multi:softprob", num_class = 3,
                        nfold = K, nthread = 2, print = F)
    min_err <- mean(cv.output)
    
    if (min_err < best_err){
      best_M <- nround[i]
      best_err <- min_err
    }
    print(list(min_err, best_M, best_err))
  }
  return(list(best_M, best_err))
}


## ADAboost
library("adabag")
adaboost <- function(dat_train){
  # dat_train is a dataframe with a column named "labels"
  begin = Sys.time()
  ada_fit = boosting(label~., dat_train, mfinal=100, coeflearn="Zhu")
  end = Sys.time()
  end-begin
  return(list(ada_fit, end-begin))
}


## Logistic Regression
logr_train <- function(dat_train){
  # dat_train is a dataframe with a column named "label_train"
  library(nnet)
  logr.fit <- multinom(label_train~., 
                    data = dat_train, 
                    MaxNWts=10000)
  return(logr.fit)
}


## SVM
svm_train <- function(dat_train, label_train){
  library(e1071)
  library(dplyr)
  svm.fit <- svm(x = dat_train, y = label_train,   
                 kernel="radial", scale = F, type = "C-classification")
  return(svm.fit)
}

