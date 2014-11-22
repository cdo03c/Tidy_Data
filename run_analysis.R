run_analysis <- function(){
    ## This section retireves and unpacks the zip file containing the data.
    if(!file.exists("./data")){dir.create("./data")}
    if(!file.exists("./data//getdata_projectfiles_UCI HAR Dataset.zip")){download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "./data/getdata_projectfiles_UCI HAR Dataset.zip")}
    unzip(zipfile = "./data/getdata_projectfiles_UCI HAR Dataset.zip", exdir = "./data")
    
    
  ##This section reads in the names for all the columns and then reads in both 
  ##the train and test data sets and combines them into one dataset.
  colnames <- read.table(file = "./data/UCI HAR Dataset/features.txt")
  
  test <- read.table(file = "./data/UCI HAR Dataset/test/X_test.txt", col.names = colnames[,2])
  train <- read.table(file = "./data/UCI HAR Dataset/train/X_train.txt", col.names = colnames[,2])
  
  joineddata <- rbind(test, train)
  
  ##This section subsets the combined dataset by columns that contain just
  ##the mean and standard deviation of the various variables.
  meancols <- grep("mean", names(joineddata))
  stdcols <- grep("std", names(joineddata))
  subsetcols <- sort.int(c(meancols, stdcols))
  joineddata <- joineddata[,subsetcols]

  ##This section loads in the subject and activity lists from test and train
  ## data sets and merges each into a complete activites and and subjests table.
  trainacts <- read.table(file = "./data/UCI HAR Dataset/train/y_train.txt", col.names = "activities")
  trainsubjects <- read.table(file = "./data/UCI HAR Dataset/train/subject_train.txt", col.names = "subjects")
  testacts <- read.table(file = "./data/UCI HAR Dataset/test/y_test.txt", col.names = "activities")
  testsubjects <- read.table(file = "./data/UCI HAR Dataset/test/subject_test.txt", col.names = "subjects")
  
  activities <- rbind(testacts, trainacts)
  subjects <- rbind(testsubjects, trainsubjects)
  
  ##This section replaces the integer values in the activities table with 
  ##descriptive names.
  activity_labels <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
  for(i in 1:length(activity_labels)){
      activities <- replace(activities, activities == i, activity_labels[i])
  }
  
  ##This section combines the subjects and activities columns with the rest
  ##of the dataset.
  joineddata <- cbind(subjects, activities, joineddata)
  
  ##This section creates a tidy data set by using triple for loops to create
  ##averages for each subject and each activity.
  tidy_data <- data.frame()
  count <- 0
  for (i in levels(as.factor(joineddata$subjects))){
      for (j in levels(as.factor(joineddata$activities))){
          parseddata <- subset(joineddata, joineddata$subjects == i)
          parseddata <- subset(parseddata, parseddata$activities == j)
          count <- count + 1
          tidy_data[count, 1] <- i
          tidy_data [count, 2] <- j
          for (k in 3:ncol(parseddata)){tidy_data [count, k] <- mean(parseddata[,k])}
     }
  }
  
  ##This section puts the proper names on the Tidy_Data data set and
  ##writes it out as a .txt file.
  colnames(tidy_data) <- names(joineddata)
  write.table(tidy_data, file = "./data/tidy_data.txt")
}