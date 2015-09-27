---
title: "Documentation for run_analysis.R"
output: html_document
---
This file describe the implementation and ideas of the R-File run_analysis.R


This script handels the Data from 
<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>
 In detail the script performs the following functionality: 

 * Merges the training and the test sets to create one data set.
 * Extracts only the measurements on the mean and standard deviation for each measurement. 
 * Uses descriptive activity names to name the activities in the data set
 * Appropriately labels the data set with descriptive variable names. 
 * From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The unziped Data of getdata_projectfiles_UCI HAR Dataset.zip schoud be located in the working directory. So that working directory contains the folder "UCI HAR Dataset".

Start the process by calling "run()" - function

The script contains 5 functions: 
* add_subject ... add a column with the subjects as seperate to a given data frame
* add_activity ... add the activity information as seperate column to a given data frame
* load_file ... load file whith the main data and retruns a data frame
* search_in_file ... retruns a list of line numbers which match a searchstring ("-mean()" and "-std()") in the mentened column
* run ... contains the main logic


The main logic in the run function executes following steps:
* load train data set
* load test data set 
* Extracts only the measurements on the mean and standard deviation for each measurement. Determine the index of the interested collumns (mean and standard)see >UCI HAR Dataset/features_info.txt  and UCI HAR Dataset/features.txt. Only columns with names contains "mean()" and "std()" are relevant. Select only columns for mean and standard 
* Rename selected columns. Set Appropriately labels the data set with descriptive variable names. 
* Get the descriptivion for activity out of the activity_labels.txt join/merge it with dataset and add activity.
* Add subject information to train and test data.
* Merges the training and the test sets to create one data set to tidy_data.
* Create from the tidy_data data set,  a second, independent tidy data set with the average of each variable for each activity and each subject. Use aggreate function
* Remove duplicated columns, generates by aggreate.
* Rename columns
* Write tidy_data_avg to disk


The codebook for the result data Set is located in file codebook.txt 
