# Creates a valid submission for the 2021 qualification task by using rpart.
# You might need to adapt or create the "OUTPUT_DIR" before running the script.

# library(rpart) # should be installed, but we use functions only with package name

OUTPUT_DIR <- "submissions/Jakob_uxxxx_123/"

# Read in
trainValues <- read.csv("data/train_values.csv", quote = "", sep = "|")
trainLabels <- read.csv("data/train_labels.csv", quote = "", sep = "|", stringsAsFactors = TRUE)
testValues <- read.csv("data/test_values.csv", quote = "", sep = "|")

# Train model
rpartModel <- rpart::rpart(formula = target ~ ., data = cbind(trainValues, trainLabels))

# Predict
testPrediction <- predict(rpartModel, newdata = testValues, type = "class")

# Write solution
write.csv(data.frame(target = testPrediction), file = paste0(OUTPUT_DIR, "Jakob_rpart_prediction.csv"),
          row.names = FALSE, quote = FALSE)
