library(reshape2)
library(data.table)
setwd("/Learning/GetCleanData/UCI HAR Dataset")
#Read in the testData
testData  <- read.table("/Learning/GetCleanData/UCI HAR Dataset/test/X_test.txt")
testDataLabel  <- read.table("/Learning/GetCleanData/UCI HAR Dataset/test/Y_test.txt")
testData  <- cbind(testDataLabel, testData)
#Read in the trainData
trainData  <- read.table("/Learning/GetCleanData/UCI HAR Dataset/train/X_train.txt")
trainDataLabel  <- read.table("/Learning/GetCleanData/UCI HAR Dataset/train/Y_train.txt")
trainData  <- cbind(trainDataLabel, trainData)
#combine test and train data sets.
combinedData  <- rbind(testData, trainData)
#add an empty column and name is ActivitiesNames
combinedData  <- cbind(seq_along(combinedData$V1), combinedData)
colnames(combinedData)[1]  <- "ActivitiesNames"
#name the second column of interge values of the activities.
colnames(combinedData)[2]  <- "activities"

#create a string to be used as the labels for the activities and fill up the ActivityName column
activities  <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
combinedData$ActivityName  <- factor(combinedData$activities, labels = activities)
combinedData[,1]  <- factor(combinedData$activities, labels = activities)

# reading the subject table to identify the participants.
subjectTestData  <- read.table("/Learning/GetCleanData/UCI HAR Dataset/test/subject_test.txt")
subjectTrainData  <- read.table("/Learning/GetCleanData/UCI HAR Dataset/train/subject_train.txt")
subjectData  <- rbind(subjectTestData, subjectTrainData)
combinedData  <- cbind(subjectData, combinedData)
colnames(combinedData)[1]  <- "participants"

# read feature name from table
featureData  <- read.table("/Learning/GetCleanData/UCI HAR Dataset/features.txt")
# convert the levels of the feature names into string and apply to the combinedData
colnames(combinedData)[4:564] <- as.character(featureData$V2)

# find the columnes with the mean or std measurement
extraCol <- grepl("mean|std", colnames(combinedData))
# create a new extracted DF containing the participants, activities and mean and std measurements.
tidyData <- cbind(combinedData[,c(1,3)], combinedData[,extraCol])
# reshape the tidyData by using the participants and activities as the id variables for each measurement
tidyDataMelt <- melt(tidyData, id = c("participants", "activities"))
# participants and activities are the id variables (we want a column for each combination of them), 
# variable is the description of the measurement, 
# use mean function to apply to the values of each combination of the id variables.
tidyDataMean <- dcast(tidyDataMelt, participants+activities~variable,mean)

# write the tidy data set to a file
write.csv(tidy, "tidy.csv", row.names=FALSE)