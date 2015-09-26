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
meanStdSet <- select(fullSet, subject, activity, contains("mean"), contains("std"))

## Neaten up variable names

varNames <- names(meanStdSet)
varNames <- gsub("\\.{3}", "_", varNames)
varNames <- gsub("\\..$", "", varNames)
varNames <- gsub("\\.{1}", "_", varNames)
varNames <- tolower(varNames)
names(meanStdSet) <- varNames

## meanStdSet is done!

## Now go through a complex set of manipulations to get a tidy means
## set ready for export

horizSet <- melt(meanStdSet, id.vars = c("subject", "activity"),
                 variable.name = c("test_var"), value.name = "test_val")
horizSet <- horizSet %>%
  ungroup () %>%
  group_by(subject, activity, test_var) %>%
  dplyr::summarize(mean = mean(test_val))

tidyMeans <- dcast(horizSet, subject + activity ~ test_var)
write.table(tidyMeans, "./tidy means - accel set.txt", row.names = F)

## Done!