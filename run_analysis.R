#############################
## Description of File:
#############################
## This file contains script composed of functions and commandes to clean a dataset and 
## prepare it for later anaylysis.
##
## This script handels the Data form 
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
##
## In detail the script performs the following functionality: 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## 
##
## The unziped Data of getdata_projectfiles_UCI HAR Dataset.zip schoud be located in the working 
## directory. So that working directory contains the folder "UCI HAR Dataset".
##
## Start the process by calling "run()" - function

# setup path and file variables
data_dir <- "UCI HAR Dataset"


## create a function to add a column with the subjects to data:
## 1.  data ... to add subject column 
## 2.  test_training ... tells whether the function works on "train" or "test" directory
## retruns data with a new subject column
add_subject <- function(data, test_train){
  fileprefix <- "subject" # subject_train.txt
  path <- paste("./",data_dir,"/",test_train,"/",fileprefix,"_",test_train,".txt",sep = "")#
  subject <- read.csv(file = path,col.names= c("subject_ID"), sep = " "
                       ,nrows= 10 # test
  ) 
  data <- cbind(data,subject) 
}


## create a function that add the activity information as seperate column to the given data
## 1.  data ... to add activity collumn 
## 2.  test_training ... tells wether the function works on "train" or "test" directory
## retruns data with a new activity collumn
add_activity <- function(data, test_train){
  library(dplyr)
  
  fileprefix <- "y" # y_train.txt
  activity_id_colname <- "activity_ID"
  path <- paste("./",data_dir,"/",test_train,"/",fileprefix,"_",test_train,".txt",sep = "")#
  activitY <- read.csv(file = path,col.names= c(activity_id_colname), sep = " "
                       ,nrows= 10 # test
                       ) 
  data <- cbind(data,activitY) 
  
  # load activity_labels.txt to Link the class labels with their activity name.
  path <- paste("./",data_dir,"/","activity_labels.txt",sep = "") 
  activity_labels <- read.csv(file = path,col.names= c(activity_id_colname, "activity"), sep = " "
                       ,nrows= 10 # test
                       ) 
  # merge the activity labels and data
  data_activity <- merge(x=data,y=activity_labels, by=activity_id_colname)
  # remove activity_id_colname column
  data_activity <-  data_activity[,!(colnames(data_activity) == activity_id_colname)]
}

## create a function to load file:
# 1.  fileprefix ... prefix of file name / filename without "_train" or "_test"
# 2.  test_training ... tells wether the function works on "train" or "test" directory
## retruns data 
load_file <- function(fileprefix,test_training){
  path <- paste("./",data_dir,"/",test_training,"/",fileprefix,"_",test_training,".txt",sep = "")#
  colwidths = rep(16,561) # 561 columns each 16byte wide 
  data <- read.fwf(file = path,widths=colwidths,colClasses = rep("numeric",561)
                   ,n = 10 # test
                   )
}


## create a function list of line numbers which match a searchstring ("-mean()" and "-std()") in the mentened column:
# 1.  filename ... name of file
## return Dataframe index + columnname 
search_in_file <- function(filename){
  library(dplyr)
  path <- paste("./",data_dir,"/",filename,sep = "")
  features <- read.table(file = path,sep = " ") 
  
  idx_mean <- features[grep("-mean\\(\\)",features$V2),]
  idx_std <- features[grep("-std\\(\\)",features$V2),]
  
  idx <- rbind(idx_mean,idx_std)
  idx <- arrange(idx, V1)
}


## create a function to start prozess to clean a dataset and export an aggregation 
run <- function(){
  
  # load traing data set 
  traindata <- load_file("X","train")
  
  # load test data set 
  testdata <- load_file("X","test")
  
  
  ## Extracts only the measurements on the mean and standard deviation for each measurement. 
  # determine the index of the interested collumns (mean and standard)
  # see >UCI HAR Dataset/features_info.txt  and UCI HAR Dataset/features.txt
  # only columns with names contains "mean()" and "std()" are relevant
  # select only columns for mean and standard 
  
  idx <- search_in_file("features.txt")
  
  traindata_relevant <- traindata[,idx[,"V1"]]
  testdata_relevant <- testdata[,idx[,"V1"]]
  
  # rename selected columns
  # Appropriately labels the data set with descriptive variable names. 
  names(traindata_relevant) <- idx$V2
  names(testdata_relevant) <- idx$V2
  
  # get the descriptivion for activity out of the activity_labels.txt
  # join/merge it with dataset and add activity information
  traindata_relevant <- add_activity(traindata_relevant,"train")
  testdata_relevant <- add_activity(testdata_relevant,"test")
  
  # add subject information
  traindata_relevant <- add_subject(traindata_relevant,"train")
  testdata_relevant <- add_subject(testdata_relevant,"test")
  
  # Merges the training and the test sets to create one data set to tidy_data.
  tidy_data <- rbind(traindata_relevant,testdata_relevant)
  
  ## create from the tidy_data data set,  a second, independent tidy data set with the average of each variable for each activity and each subject.
  tidy_data_avg <- aggregate(x=tidy_data,by=list(tidy_data$activity,tidy_data$subject_ID), FUN="mean", na.rm=TRUE)
  
  # remove duplicated columns, generates by aggreate
  tidy_data_avg <-  tidy_data_avg[,!(colnames(tidy_data_avg) == "activity")]
  tidy_data_avg <-  tidy_data_avg[,!(colnames(tidy_data_avg) ==  "subject_ID")]
  
  # rename columns
  library(plyr)
  tidy_data_avg <- rename(tidy_data_avg, c("Group.1" = "activity", "Group.2" = "subject_ID"))
  
  # write tidy_data_avg to disk
  write.table(tidy_data_avg,file = "./tidy_data_avg.txt",row.names = FALSE)
  tidy_data_avg # return value
}
