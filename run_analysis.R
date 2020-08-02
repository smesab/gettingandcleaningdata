##0
##libraries to be used
library(dplyr)

##create folder in case is needed
if(!file.exists("./data")){
        dir.create("./data")
}

##download file and unzip in the same destfile
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./data/data.zip",method="curl")
unzip("./data/data.zip",exdir="./data/")

## read the data
features <- read.table("./data/UCI HAR Dataset/features.txt", col.names = c("n","signals"))
##Train
subjectTR <- read.table('./data/UCI HAR Dataset/train/subject_train.txt',header=FALSE,col.names="subject")
xTR <- read.table('./data/UCI HAR Dataset/train/x_train.txt',header=FALSE,col.names=features$signals)
yTR <- read.table('./data/UCI HAR Dataset/train/y_train.txt',header=FALSE,col.names="activity")
##Test
subjectTE <- read.table('./data/UCI HAR Dataset/test/subject_test.txt',header=FALSE,col.names="subject")
xTE <- read.table('./data/UCI HAR Dataset/test/x_test.txt',header=FALSE,col.names=features$signals)
yTE <-read.table('./data/UCI HAR Dataset/test/y_test.txt',header=FALSE,col.names="activity")
## 1 Merges the training and the test sets to create one data set.
subject<-rbind(subjectTR,subjectTE)
x<-rbind(xTR,xTE)
y<-rbind(yTR,yTE)
mergedData<-mutate(subject,x,y)

## 2 Extracts only the measurements on the mean and standard deviation for each measurement.
meansdData<-select(mergedData,subject,activity,contains("mean")|contains("std"))

## 3 Uses descriptive activity names to name the activities in the data set
activities <- read.table('./data/UCI HAR Dataset/activity_labels.txt',header=FALSE,col.names=c("activity","name"))
meansdData$activity<-activities[meansdData$activity,2]

## 4 Appropriately labels the data set with descriptive variable names.
names(meansdData)<-gsub("std()", "sd", names(meansdData))
names(meansdData)<-gsub("mean()", "mean", names(meansdData))
names(meansdData)<-gsub("^t", "Time", names(meansdData))
names(meansdData)<-gsub("^f", "Frequency", names(meansdData))
names(meansdData)<-gsub("Acc", "Accelerometer", names(meansdData))
names(meansdData)<-gsub("Gyro", "Gyroscope", names(meansdData))
names(meansdData)<-gsub("Mag", "Magnitude", names(meansdData))
names(meansdData)<-gsub("BodyBody", "Body", names(meansdData))
## 5 creates a second, independent tidy data set with the average of each variable for each activity and each subject.

tidyData<-group_by(meansdData,subject,activity) %>% summarise_each(list(mean=mean))
write.table(tidyData,"tidyData.txt",row.name=FALSE)
