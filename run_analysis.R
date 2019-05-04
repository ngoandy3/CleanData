#create the directory if the file data is not there
if(!file.exists("data")) {
        dir.create("data")
}

#store the url in var fileUrl
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#download the file and store it in uci.zip w/ method = curl b/c https
download.file(fileUrl, destfile = "uci.zip", method = "curl")

#unzip the data since it is a zip file
unzip("./data/uci.zip")

#read in at site where data was obtained
fileUrl <- "http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones"
download.file(fileUrl, destfile = "uci.names")

#read in train data
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

#read in test data
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#read in features and take only the second column
features <- read.table("./UCI HAR Dataset/features.txt")
features <- features[, 2]

#turn all of train and test data into own separate data frame
data_train <- data.frame(subject_train, y_train, x_train)
names(data_train) <- c(c("subject", "activity"), as.character(features))
data_test <- data.frame(subject_test, y_test, x_test)
names(data_test) <- c(c("subject", "activity"), as.character(features))

#merge the training and testing sets into 1 dataset
all <- rbind(data_train, data_test)

#extract measurements on the mean and standard deviation for each measurement
mean_std.select <- grep("mean|std", features)
data.sub <- all[, c(1, 2, mean_std.select + 2)]

#use descriptive activity names to name the activities in the data set
#read in the data
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)

#convert to character column 2
activity_labels <- as.character(activity_labels[, 2])

#attach the names
data.sub$activity <- activity_labels[data.sub$activity]

#label the data set with descriptive variable names
name_new <- names(data.sub)
name_new <- gsub("[(][)]", "", name_new)
name_new <- gsub("^t", "TimeDomain_", name_new)
name_new <- gsub("^f", "FrequencyDomain_", name_new)
name_new <- gsub("Acc", "Accelerometer", name_new)
name_new <- gsub("Gyro", "Gyroscope", name_new)
name_new <- gsub("Mag", "Magnitude", name_new)
name_new <- gsub("-mean-", "_Mean_", name_new)
name_new <- gsub("-std-", "_StandardDeviation_", name_new)
name_new <- gsub("-", "_", name_new)
names(data.sub) <- name_new

#create a second independent tidy data set with the average of each variable for each activity and each subject
data_tidy <- aggregate(data.sub[, 3:81], by = list(activity = data.sub$activity, subject = data.sub$subject), FUN = mean)
write.table(data_tidy, "data_tidy.txt", row.names= FALSE)