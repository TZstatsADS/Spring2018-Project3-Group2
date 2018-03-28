################################
###### Feature Extraction ######
################################

############# RGB ##############
feature_rgb <- function(img_dir, export=T){
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  ### load libraries
  library("EBImage")
  library(grDevices)
  ### Define the b=number of R, G and B
  nR <- 6
  nG <- 16
  nB <- 16 
  rBin <- seq(0, 1, length.out=nR)
  gBin <- seq(0, 1, length.out=nG)
  bBin <- seq(0, 1, length.out=nB)
  mat=array()
  freq_rgb=array()
  rgb_feature=matrix(nrow=3000, ncol=nR*nG*nB)
  
  n_files <- length(list.files(img_dir))
  
  ### extract RGB features
  for (i in 1:3000){
    mat <- imageData(readImage(paste0(img_dir, sprintf("%04.f",i), ".jpg")))
    mat_as_rgb <-array(c(mat,mat,mat),dim = c(nrow(mat),ncol(mat),3))
    freq_rgb <- as.data.frame(table(factor(findInterval(mat_as_rgb[,,1], rBin), levels=1:nR), 
                                    factor(findInterval(mat_as_rgb[,,2], gBin), levels=1:nG),
                                    factor(findInterval(mat_as_rgb[,,3], bBin), levels=1:nB)))
    rgb_feature[i,] <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
    
    mat_rgb <-mat_as_rgb
    dim(mat_rgb) <- c(nrow(mat_as_rgb)*ncol(mat_as_rgb), 3)
  }
  
  ### output RGB features
  if(export){
    saveRDS(rgb_feature, file = "../output/rgb_feature_new3.RData")
  }
  return(data.frame(rgb_feature))
}


############# HoG ##############
feature_hog<-function(img_dir, export=TRUE){
  
  ### Construct process features for training/testing images
  ### HOG: calculate the Histogram of Oriented Gradient for an image
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  
  ### load libraries
  library("EBImage")
  library("OpenImageR")
  
  dir_names <- list.files(img_dir)
  n_files <- length(dir_names)
  
  ### calculate HOG of images
  dat <- matrix(NA, n_files, 54) 
  for(i in 1:n_files){
    img <- readImage(paste0(img_dir,  dir_names[i]))
    dat[i,] <- HOG(img)
  }
  
  ### output constructed features
  if(export){
    save(dat, file=paste0("../output/HOG.RData"))
  }
  return(dat)
}


############# Gray ##############
feature_gray <- function(img_dir, export=TRUE){
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  ### load libraries
  library("EBImage")
  
  img_names = list.files(img_dir)
  img_n = length(img_names)
  bin = seq(0,1,length.out =  250)
  
  gray_feature <- data.frame(matrix(NA,img_n,251))
  names(gray_feature) = c('Image',paste('gray_',1:250,sep=""))
  gray_feature$Image = img_names
  
  for(i in 1:img_n){
    # read each image
    img = readImage(paste(img_dir,img_names[i],sep="/"))
    # change image to gray
    img = channel(img,"gray")
    img = resize(img,256,256)
    mat = imageData(img)
    # count the frequency 
    gray_freq <- as.data.frame(table(factor(findInterval(mat, bin), levels = 1:250)))
    gray_feature[i,2:251] <- as.numeric(gray_freq$Freq)/(ncol(mat)*nrow(mat))
  }
  
  ### output constructed features
  if(export){
    save(gray_feature, file=paste0("../output/gray.RData"))
  }
  return(gray_feature)
}

############# PCA ##############
feature_pca <- function(dat_feature, cumulate.upper.bound = 0.9){
  
  # Run PCA on features
  feature.pca <- prcomp(as.data.frame(dat_feature), center = TRUE, scale = TRUE)
  summary.pca <- summary(feature.pca)
  sd.pca <- summary.pca$sdev
  prop_var <- summary.pca$importance[2, ]
  cum_var <- summary.pca$importance[3,]
  
  # PCA threshold values
  thre <- which(cum_var >= cumulate.upper.bound)[1]
  
  # Extract first N PCAs based on threshold values
  pca_thre <- as.matrix(dat_feature) %*% feature.pca$rotation[,c(1:thre)]
  
  # save file
  #save(pca_thre, file = paste("../../output/extracted.pca", threshold, ".RData"))
  
  return(pca_thre)
}


