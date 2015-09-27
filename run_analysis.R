## Data Cleaning Final - Analysis Code
##
## Andareiro, 26 September 2015

## Load up the requisite libraries

library(reshape2)
library(plyr)
library(dplyr)


## Go fetch and unzip our data
dataURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataURL, destfile="./fuci_dataset.zip")
unzip("./fuci_dataset.zip")

## Create lists for labels and features

featuresLabels = read.table("./UCI HAR Dataset/features.txt")

trainSubjects = read.table("./UCI HAR Dataset/train/subject_train.txt", col.names="subject")
trainLabels = read.table("./UCI HAR Dataset/train/y_train.txt", col.names="label")
trainSet = read.table("./UCI HAR Dataset/train/X_train.txt", col.names=featuresLabels$V2)
trainSet = cbind(trainSubjects, trainLabels, trainSet)

testSubjects = read.table("./UCI HAR Dataset/test/subject_test.txt", col.names="subject")
testLabels = read.table("./UCI HAR Dataset/test/y_test.txt", col.names="label")
testSet = read.table("./UCI HAR Dataset/test/X_test.txt", col.names=featuresLabels$V2)
testSet = cbind(testSubjects, testLabels, testSet)

## Mark the two data sets before binding
testSet$data_set <- "test"
trainSet$data_set <- "train"

## Join training and train data sets together
fullSet = rbind(trainSet, trainSet)

## Neaten up and join on the activity labels
activityLabels = read.table("./UCI HAR Dataset/activity_labels.txt", col.names=c("id", "activity"))
activityLabels$activity <- tolower(activityLabels$activity)
fullSet <- left_join(fullSet, activityLabels, by = c("label" = "id"))

## Create a data set of the mean and std deviation values for all the entries
meanStdSet <- select(fullSet, subject, activity, contains("mean"), contains("std"),
                     -contains("angle"))

## To make our data tidy, melt it so that we have a single colume for the test
## values

horizSet <- melt(meanStdSet, id.vars = c("subject", "activity"),
                 variable.name = c("test_var"), value.name = "test_val")

## Go ahead and calculate the mean for all the variables

horizSet <- horizSet %>%
  ungroup () %>%
  group_by(subject, activity, test_var) %>%
  dplyr::summarize(mean = mean(test_val))

## Final step to make our data tidy, recode the variable names into actual 
## data fields, based on data in features_info.txt

## Make the names lowercase and easier to handle
horizSet$test_var <- tolower(horizSet$test_var)

## Instrument type
horizSet$instrument[grepl("acc",  horizSet$test_var) ] <- "accelerometer"
horizSet$instrument[grepl("gyro",  horizSet$test_var) ] <- "gyroscope"

## Signal domain type
horizSet$signal[grepl("^f",  horizSet$test_var) ] <- "frequency"
horizSet$signal[grepl("\\_f",  horizSet$test_var) ] <- "frequency"
horizSet$signal[grepl("^t",  horizSet$test_var) ] <- "time"
horizSet$signal[grepl("\\_t",  horizSet$test_var) ] <- "time"

## Signal type
horizSet$signal_type[grepl("body",  horizSet$test_var) ] <- "body"
horizSet$signal_type[grepl("gravity",  horizSet$test_var) ] <- "gravity"

## Jerk signal, yes or no
horizSet$jerk[grepl("jerk",  horizSet$test_var) ] <- "jerk"

## Calculation
horizSet$calc[grepl("mag",  horizSet$test_var) ] <- "magnitude"

## Summary statistic
horizSet$statistic[grepl("mean",  horizSet$test_var) ] <- "mean"
horizSet$statistic[grepl("meanfreq",  horizSet$test_var) ] <- "mean frequency"
horizSet$statistic[grepl("std",  horizSet$test_var) ] <- "std dev"

## Axis
horizSet$axis[grepl("\\_x",  horizSet$test_var) ] <- "x"
horizSet$axis[grepl("\\_y",  horizSet$test_var) ] <- "y"
horizSet$axis[grepl("\\_z",  horizSet$test_var) ] <- "z"

## Remove that hideous test variable

horizSet$test_var <- NULL

## Looks good - write out the table

write.table(tidyMeans, "./tidy means - accel set.txt", row.names = F)

## Done!