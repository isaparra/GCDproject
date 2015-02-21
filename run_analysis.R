# Downloading files and reading data

if (!file.exists("./data")) {dir.create("./data")}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,dest="./data/samsung.zip")
unzip("./data/samsung.zip")

x_train<-read.table('./UCI HAR Dataset/train/X_train.txt')
y_train<-read.table('./UCI HAR Dataset/train/y_train.txt')
subject_train<-read.table('./UCI HAR Dataset/train/subject_train.txt')


x_test<-read.table('./UCI HAR Dataset/test/X_test.txt')
y_test<-read.table('./UCI HAR Dataset/test/y_test.txt')
subject_test<-read.table('./UCI HAR Dataset/test/subject_test.txt')

features <-read.table('./UCI HAR Dataset/features.txt')


# Merges the training and the test sets to create one data set

colnames(x_test)<-features$V2
colnames(subject_test)<-"Subject"
colnames(y_test)<-"Activity"
data_test<-cbind(subject_test, y_test, x_test)

colnames(x_train)<-features$V2
colnames(subject_train)<-"Subject"
colnames(y_train)<-"Activity"
data_train<-cbind(subject_train, y_train, x_train)

data_set<-rbind(data_train,data_test)


install.packages("gdata")
library(gdata)

mean_cols <- matchcols(data_set, with=c("mean"), without=c("meanFreq"))
std_cols  <- matchcols(data_set, with=c("std"))
new_cols <- c(mean_cols, std_cols)
subdata<-data_set[,c("Subject","Activity",new_cols)]

# Uses descriptive activity names to name the activities in the data set

activity_labels <-read.table('./UCI HAR Dataset/activity_labels.txt')
subdata_l <- subdata

    ## I name the activities in a new data frame subdata_l
for(i in 1:6) {
  subdata_l$Activity[subdata_l$Activity==i]<-as.character(activity_labels$V2[i])
}

# Appropriately labels the data set with descriptive variable names
subdata<-rename.vars(subdata,c("fBodyBodyAccJerkMag-mean()","fBodyBodyGyroJerkMag-mean()",
                               "fBodyBodyGyroMag-mean()", "fBodyBodyGyroMag-std()",
                               "fBodyBodyAccJerkMag-std()", "fBodyBodyGyroJerkMag-std()"), 
                     c("fBodyAccJerkMag-mean", "fBodyGyroJerkMag-mean", 
                       "fBodyGyroMag-mean", "fBodyGyroMag-std", "fBodyAccJerkMag-std",
                       "fBodyGyroJerkMag-std")
                     )

#From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject

means<-aggregate(subdata, by=list(subdata$Subject,subdata$Activity), mean)
     # With subdata_l (with activity names) this function gives a warning


  ## I include the name of activities in the data frame means

for(i in 1:6) {
  means$Activity[means$Activity==i]<-as.character(activity_labels$V2[i])
}

  ## I remove the variables created by aggregate() function. They match "Subject"
  ## and "Activity" variables
df <- subset(means, select = -c(Group.1,Group.2) )

write.table(df, "step5.txt", row.name=FALSE)
