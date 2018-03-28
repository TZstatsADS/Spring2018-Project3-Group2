
"""
Created on Tue Mar 21 19:49:48 2018
@author: Du Guo
"""
def extract_lbp(img_dir,type='train'):
    # OpenCV bindings
    import cv2
    # To performing path manipulations 
    #import os 
    from os import listdir
    # Local Binary Pattern function
    from skimage import feature
    from scipy.stats import itemfreq
    import pandas as pd
    #from sklearn.preprocessing import normalize
    # Utility package -- use pip install cvutils to install
    #import cvutils
    # To read class from file
    #import csv
    img_dir = "/Users/duguo/Documents/coursesbook/applied DS/project3/train/images"
    path1 =img_dir
    image_lists = sorted(listdir(path1))
    image_dir_list = []
    for i in range(len(image_lists)):
        image_dir_list.append(path1+"/"+image_lists[i])
              
    his = [] 
    for i in range(len(image_dir_list)):
        im = cv2.imread(image_dir_list[i], cv2.IMREAD_ANYCOLOR)
        im_gray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
        radius = 3
        no_points = 8 * radius
        lbp = feature.local_binary_pattern(im_gray, no_points, radius, method='uniform')
        x = itemfreq(lbp.ravel())
        hist = x[:, 1]/sum(x[:, 1])
        his.append(hist)
        print(i)
    
    lbp_df=pd.DataFrame(his)
    # write csv to local file
    lbp_df.to_csv("./lbp_"+type+".csv",index=False)

