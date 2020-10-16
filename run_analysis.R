require(data.table)
require(dplyr)
filename <- "DataCleaningDataset.zip"

#checking if archieve already exists.
if (!file.exists(filename)){
	fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(fileURL, filename, method="curl")
}  

#checking if folder exists
if (!file.exists("UCI HAR Dataset")) { 
	unzip(filename) 
}

#importing the data from each file
features <- fread("UCI HAR Dataset/features.txt", col.names = c("number", "features"))
activites <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("labels", "activities"))
subject_test <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = "subject_id")
subject_train <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = "subject_id")
X_test <- fread("UCI HAR Dataset/test/X_test.txt", col.names = features[,features])
Y_test <- fread("UCI HAR Dataset/test/Y_test.txt", col.names = "labels")
X_train <- fread("UCI HAR Dataset/train/X_train.txt", col.names = features[,features])
Y_train <- fread("UCI HAR Dataset/train/Y_train.txt", col.names = "labels")

#merging the data
X_data <- rbind(X_test, X_train)
Y_data <- rbind(Y_test, Y_train)
subject_id_data <- rbind(subject_test, subject_train)
merged_data <- cbind(subject_id_data, Y_data, X_data)
colnames(merged_data)

#tidying the data
tidy_data <- merged_data %>% select(subject_id, labels, contains("mean"), contains("std"))

#naming the activities
activity_names <- activites[tidy_data[,labels],activities]
tidy_data[,labels:=activity_names]

#changing variable names
setnames(tidy_data, "labels", "activity")
setnames(tidy_data, names(tidy_data), gsub("acc", "Accelerometer", names(tidy_data)))
names(tidy_data)<-gsub("Acc", "Accelerometer", names(tidy_data))
names(tidy_data)<-gsub("Gyro", "Gyroscope", names(tidy_data))
names(tidy_data)<-gsub("BodyBody", "Body", names(tidy_data))
names(tidy_data)<-gsub("Mag", "Magnitude", names(tidy_data))
names(tidy_data)<-gsub("^t", "Time", names(tidy_data))
names(tidy_data)<-gsub("^f", "Frequency", names(tidy_data))
names(tidy_data)<-gsub("tBody", "TimeBody", names(tidy_data))
names(tidy_data)<-gsub("-mean()", "Mean", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("-std()", "STD", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("-freq()", "Frequency", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("angle", "Angle", names(tidy_data))
names(tidy_data)<-gsub("gravity", "Gravity", names(tidy_data))

#summarising the data
summary_data <- aggregate(tidy_data[, !c("activity", "subject_id")], list(tidy_data$subject_id, tidy_data$activity), mean)