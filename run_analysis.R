
## Go fetch and unzip our data
dataURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataURL, destfile="./fuci_dataset.zip")
unzip("./fuci_dataset.zip")

## Set our working directory to the data
setwd("./UCI HAR Dataset")

## Create lists for labels and features

activityLabels = read.table("activity_labels.txt", col.names=c("id", "Activity"))
featuresLabels = read.table("features.txt")



trainSubjects = read.table("train/subject_train.txt", col.names="Subject")
trainLabels = read.table("./train/y_train.txt", col.names="Label")
trainSet = read.table("./train/X_train.txt", col.names=featuresLabels$V2)
trainActivity <- merge(trainLabels, activityLabels, by.x="Label", by.y="id", all=T)
trainSet = cbind(trainSubjects, Activity = trainActivity$Activity, trainSet)

testSubjects = read.table("test/subject_test.txt", col.names="Subject")
testLabels = read.table("./test/y_test.txt", col.names="Label")
testSet = read.table("./test/X_test.txt", col.names=featuresLabels$V2)
testActivity <- merge(testLabels, activityLabels, by.x="Label", by.y="id", all=T)
testSet = cbind(testSubjects, Activity = testActivity$Activity, testSet)

## Stick the trianing and train data sets together
fullSet = rbind(trainSet, trainSet)

## Create a data set of the mean and std deviation values for all the entries
meanstdSet <- select(fullSet, Subject, Activity, contains("mean"), contains("std"))

## Next step is to create a data set with the averages of each variable
## by activity and subject, but I couldn't get there! This last part is
## really tough!