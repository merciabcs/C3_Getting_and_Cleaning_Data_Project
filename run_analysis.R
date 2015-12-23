library(reshape2)

# Look for File / Folder and Download / unzip if needed
if (!file.exists("getdata_dataset.zip")){
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ", "getdata_dataset.zip", method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip("getdata_dataset.zip") 
}

# Import Activity Labels and Features
feat <- read.table("UCI HAR Dataset/features.txt")
lab <- read.table("UCI HAR Dataset/activity_labels.txt")
meas_used <- grepl("mean|std",feat$V2)
feat_used <- as.character(feat$V2[meas_used]) 

# Import Test data
x_test<-read.table("UCI HAR Dataset/test/X_test.txt")[meas_used]
y_test<-read.table("UCI HAR Dataset/test/y_test.txt")
subj_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
lab_test <- merge(y_test,lab)


# Import Train data
x_train<-read.table("UCI HAR Dataset/train/X_train.txt")[meas_used]
y_train<-read.table("UCI HAR Dataset/train/y_train.txt")
subj_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
lab_train <- merge(y_train,lab)

# Make the names better presented
name_feat <- gsub('[()]',"",feat_used)
name_feat <- gsub("-mean","_Mean",name_feat)
name_feat <- gsub("-std","_Std",name_feat)
name_feat <- gsub("-","",name_feat)

# merging the data
data_test <- cbind(lab_test$V2,subj_test,x_test)
names(data_test)<-c("activity","subject",name_feat)

data_train <- cbind(lab_train$V2,subj_train,x_train)
names(data_train)<-c("activity","subject",name_feat)

data <- rbind(data_test,data_train)

any(is.na(data))

# tidy data
data$subject <- as.factor(data$subject)

melted_data <- melt(data,id=c("subject","activity"))

tidy_data <- dcast(melted_data, subject + activity ~ variable, mean)

write.table(tidy_data, "tidy.txt", row.names = FALSE, quote = FALSE)
