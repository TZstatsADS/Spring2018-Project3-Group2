### Fit the classification model with test data

## GBM
gbm_test<- function(fit_train, dat_test){
  
  library("gbm")
  pred <- predict(fit_train, newdata=dat_test, 
                  n.trees=800, type="response")
  
  return(apply(pred, 1, which.max))
}


## XGBoost
xgb_test<- function(model, x){
  
  library("xgboost")
  pred <- predict(model, as.matrix(x))
  pred <- matrix(pred, ncol=3, byrow=TRUE)
  pred_labels <- max.col(pred) - 1
  return(pred_labels)
}


## ADAboost
adapredict <- function(ada_fit, test) {
  pred_ada100 = predict.boosting(ada_fit,newdata = test)
  return(mean((as.integer(pred_ada100$class))!=test_labels))
}


## Logistic Regression and SVM
test <- function(fit_train, dat_test){
  pred <- predict(fit_train, newdata = dat_test)
  return(pred)
}


