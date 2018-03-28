### Cross Validation

## GBM
cv_gbm <- function(X.train, y.train, d, K){
  source("../lib/Train.R")
  source("../lib/Test.R")
  n <- length(y.train)
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- X.train[s != i,]
    train.label <- y.train[s != i]
    test.data <- X.train[s == i,]
    test.label <- y.train[s == i]
    
    par <- list(depth=d)
    fit <- gbm_train(train.data, train.label, par)
    pred <- gbm_test(fit, test.data)  
    cv.error[i] <- mean(pred != test.label)  
    
  }			
  return(c(mean(cv.error),sd(cv.error)))
}

## XGBoost
xgb_cv <- function(data.train, label.train, max_depth = 6, eta = 0.3, 
                   nrounds = 100, gamma = 0, nthread = 2, subsample = 0.5,
                   objective = "multi:softprob", num_class = 3, nfold=5){
  K <- nfold
  n <- length(label.train)
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- data.train[s != i,]
    train.label <- label.train[s != i]
    test.data <- data.train[s == i,]
    test.label <- label.train[s == i]
    
    par <- list(max_depth = max_depth, eta = eta)
    dtrain = xgb.DMatrix(data=data.matrix(train.data),label=train.label)
    fit <- xgb.train(data = dtrain, params = par, nrounds = nrounds, 
                     gamma = gamma, nthread = nthread, subsample = subsample,
                     objective = objective, num_class = num_class)
    pred <- predict(fit, as.matrix(test.data))
    pred <- matrix(pred, ncol=3, byrow=TRUE)
    pred_labels <- max.col(pred) - 1
    cv.error[i] <- mean(pred_labels != test.label)  
    print(cv.error[i])
  }			
  return(cv.error)
}

## Logistic Regression
cv_logr <- function(X.train, y.train, K){
  
  n <- length(y.train)
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- X.train[s != i,]
    test.data <- X.train[s == i, ]
    
    fit <- logr_train(train.data)
    pred <- logr_test(fit, test.data[, -1])  
    cv.error[i] <- mean(pred != test.data$label_train)
  }			
  return(c(mean(cv.error),sd(cv.error)))
}


## SVM
cv_nonlinear <- function(train_x, train_y, k){
  set.seed(90)
  train_time = c()
  n = length(train_y)
  n.fold = floor(n/k)
  s = sample(rep(1:k, c(rep(n.fold, k-1), n-(k-1)*n.fold)))  
  cv.error <- rep(NA, k)
  
  for (i in 1:k){
    begin <- Sys.time()
    train.data = train_x[s != i,]
    train.label = train_y[s != i]
    test.data = train_x[s == i,]
    test.label = train_y[s == i]
    
    cv.svm.model = svm(x = train.data, y = train.label, kernel="radial", type = "C-classification")
    
    pred_cv = predict(cv.svm.model, test.data)
    end <- Sys.time()
    cv.error[i]<- mean(as.numeric(pred_cv) != test.label)
    train_time[i] <- as.numeric(end - begin)
  }   	
  return(c(mean(cv.error),mean(train_time)))
}

