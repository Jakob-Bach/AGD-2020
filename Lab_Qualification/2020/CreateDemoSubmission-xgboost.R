library(data.table)
# library(xgboost) # should be installed, but we use functions only with package name

# Functions -------------------------------------------------------------------

# Computes the DMC score.
dmcScore <- function(actual, prediction) {
  tp <- sum(actual == "1" & prediction == "1")
  fp <- sum(actual == "0" & prediction == "1")
  fn <- sum(actual == "1" & prediction == "0")
  return(-5 * fn + 5 * tp - 25 * fp)
}

# Systematic features engineering. Creates all features from four groups (total,
# per value, per time, per items), while the original data have five "total"
# features, two "PerTime" and one "perItems" and are not consistent in naming.
# Currently we ignore the "trustLevel".
engineerFeatures <- function(dataset) {
  require(data.table)
  if (!is.data.table(dataset)) {
    dataset <- data.table(dataset)
  } else {
    dataset <- copy(dataset) # do not modify original
  }
  
  # "total" (= absolute value) features (mostly already in data)
  setnames(dataset, old = "totalScanTimeInSeconds", new = "Time_total")
  setnames(dataset, old = "grandTotal", new = "Value_total")
  # Total number also with lineItemVoids / lineItemVoidsPerPosition, but then NaNs
  # because sometimes no voids (else same result); round because slight numerical
  # imprecision (but should be whole numbers)
  dataset[, Items_total := as.integer(round(scannedLineItemsPerSecond * Time_total))]
  setnames(dataset, old = "lineItemVoids", new = "ItemVoids_total")
  setnames(dataset, old = "scansWithoutRegistration", new = "ScansWithoutReg_total")
  setnames(dataset, old = "quantityModifications", new = "QuantityMod_total")
  dataset[, Intervention_total := as.integer(ItemVoids_total + ScansWithoutReg_total + QuantityMod_total)]
  
  # "perValue" features (relative to grand total value)
  dataset[, Time_perValue := Time_total / Value_total]
  dataset[, Items_perValue := Items_total / Value_total]
  dataset[, ItemVoids_perValue := ItemVoids_total / Value_total]
  dataset[, ScansWithoutReg_perValue := ScansWithoutReg_total / Value_total]
  dataset[, QuantityMod_perValue := QuantityMod_total / Value_total]
  dataset[, Intervention_perValue := Intervention_total / Value_total]
  
  # "perTime" features (relative to total scan time)
  setnames(dataset, old = "valuePerSecond", new = "Value_perTime")
  setnames(dataset, old = "scannedLineItemsPerSecond", new = "Items_perTime")
  dataset[, ItemVoids_perTime := ItemVoids_total / Time_total]
  dataset[, ScansWithoutReg_perTime := ScansWithoutReg_total / Time_total]
  dataset[, QuantityMod_perTime := QuantityMod_total / Time_total]
  dataset[, Intervention_perTime := Intervention_total / Time_total]
  
  # "perItem" features (relative to total number of scanned items)
  dataset[, Value_perItems := Value_total / Items_total]
  dataset[, Time_perItems := Time_total / Items_total]
  setnames(dataset, old = "lineItemVoidsPerPosition", new = "ItemVoids_perItems")
  dataset[, ScansWithoutReg_perItems := ScansWithoutReg_total / Items_total]
  dataset[, QuantityMod_perItems := QuantityMod_total / Items_total]
  dataset[, Intervention_perItems := Intervention_total / Items_total]
  
  # dataset might contain Inf as well as NA values because division by zero
  dataset[is.na(dataset)] <- 0
  
  return(dataset)
}

# Main part -------------------------------------------------------------------

# Read in
trainData <- read.csv("data/train.csv", sep = "|", quote = "")
testData <- read.csv("data/test.csv", sep = "|", quote = "")
  
# Pre-process and engineer features
trainData <- engineerFeatures(trainData)
testData <- engineerFeatures(testData)

# Train model
xgbTrainPredictors <- Matrix::sparse.model.matrix(~ ., data = trainData[, -"fraud"])[, -1]
xgbTrainData <- xgboost::xgb.DMatrix(data = xgbTrainPredictors, label = trainData$fraud)
xgbTestPredictors <- Matrix::sparse.model.matrix(~ ., data = testData)[, -1]
xgbModel <- xgboost::xgb.train(data = xgbTrainData, nrounds = 50,
    params = list(objective = "binary:logistic", nthread = 4))
  
# Predict
trainPrediction <- predict(xgbModel, newdata = xgbTrainPredictors)
testPrediction <- predict(xgbModel, newdata = xgbTestPredictors)
threshold <- optimize(function(x) {
  dmcScore(actual = trainData$fraud, prediction = as.integer(trainPrediction >= x))
}, lower = 0, upper = 1, maximum = TRUE)$maximum
solution <- data.frame(fraud = as.integer(testPrediction >= threshold))
  
# Write solution
write.csv(solution, file = "data/Jakob_Bach-prediction.csv", row.names = FALSE, quote = FALSE)
