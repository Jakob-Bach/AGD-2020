# Creates a valid submission for the 2021 qualification task by using xgboost.
# You might need to adapt or create the "OUTPUT_DIR" before running the script.

# library(xgboost) # should be installed, but we use functions only with package name

OUTPUT_DIR <- "submissions/Jakob_uxxxx_123/"
ENGINEER_FEATURES <- TRUE

# Computes simple aggregates over the grid participants for all physical quantities.
engineer_features <- function(dataset) {
  for (quantity in unique(gsub("[1-9]", "", colnames(dataset)))) {
    for (aggFunc in c("mean", "min", "max", "sd")) {
      dataset[[paste0(quantity, "_", aggFunc)]] <- apply(dataset, MARGIN = 1, FUN = aggFunc)
    }
  }
  return(dataset)
}

# Read in
trainValues <- read.csv("data/train_values.csv", quote = "", sep = "|")
trainLabels <- read.csv("data/train_labels.csv", quote = "", sep = "|", stringsAsFactors = TRUE)
testValues <- read.csv("data/test_values.csv", quote = "", sep = "|")

# Feature engineering
if (ENGINEER_FEATURES) {
  trainValues <- engineer_features(trainValues)
  testValues <- engineer_features(testValues)
}

# Train model
xgbTrainPredictors <- Matrix::sparse.model.matrix(~ ., data = trainValues)[, -1]
xgbTrainLabels <- as.integer(trainLabels$target) - 1 # xgboost expects labels as integers starting from 0
xgbTrainData <- xgboost::xgb.DMatrix(data = xgbTrainPredictors, label = xgbTrainLabels)
xgbTestPredictors <- Matrix::sparse.model.matrix(~ ., data = testValues)[, -1]
xgbModel <- xgboost::xgb.train(data = xgbTrainData, nrounds = 50,
    params = list(objective = "binary:logistic", nthread = 4))

# Predict
testProbs <- predict(xgbModel, newdata = xgbTestPredictors)
testPrediction <- levels(trainLabels$target)[(testProbs >= 0.5) + 1]

# Write solution
write.csv(data.frame(target = testPrediction), file = paste0(OUTPUT_DIR, "Jakob_xgboost_features_prediction.csv"),
          row.names = FALSE, quote = FALSE)
