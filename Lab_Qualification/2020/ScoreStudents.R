library(data.table)

# Computes the DMC score.
dmcScore <- function(actual, prediction) {
  tp <- sum(actual == "1" & prediction == "1")
  fp <- sum(actual == "0" & prediction == "1")
  fn <- sum(actual == "1" & prediction == "0")
  return(-5 * fn + 5 * tp - 25 * fp)
}

groundTruth <- read.csv("data/DMC-2019-realclass.csv")
basePath <- "../../../../AGD_Praktikum_2020/Quali_submissions"
# Code is able to cope with multiple predicition files per dir (e.g., a normal
# one and a fixed one)
predictionFiles <- list.files(basePath, pattern = "_prediction.csv",
                              full.names = TRUE, recursive = TRUE)
studentDirs <- list.dirs(basePath, full.names = FALSE)[-1] # minus original dir
accountNames <- gsub("_", "", regmatches(studentDirs, regexpr("_u[a-z]{4}", studentDirs)))
fullNames <- gsub("_u.*", "", studentDirs)
resultTable <- rbindlist(lapply(predictionFiles, function(predictionFileName) {
  studentName <- gsub("_prediction.csv", "", basename(predictionFileName))
  filePathSplit <- strsplit(predictionFileName, "/")[[1]]
  dirIdx <- which(grepl(filePathSplit[length(filePathSplit) - 1], studentDirs))
  result <- list(Name = studentName, Full_Name = fullNames[dirIdx], Account = accountNames[dirIdx])
  prediction <- fread(predictionFileName, sep = "+", quote = "")
  if (nrow(prediction) != nrow(groundTruth)) {
     return(c(result, list(Score = NA, Issue = "Number of observations wrong.")))
  }
  if (ncol(prediction) != ncol(groundTruth)) {
    return(c(result, list(Score = NA, Issue = "Number of columns wrong.")))
  }
  if (colnames(prediction) != colnames(groundTruth)) {
    return(c(result, list(Score = NA, Issue = "Column name wrong (quoted or wrong string).")))
  }
  if (!is.numeric(prediction$fraud)) {
    return(c(result, list(Score = NA, Issue = "Data type wrong (values might be quoted).")))
  }
  if (any(prediction$fraud != 0 & prediction$fraud != 1)) {
    return(c(result, list(Score = NA, Issue = "Additional class labels.")))
  }
  score <- dmcScore(actual = groundTruth$fraud, prediction = prediction$fraud) / nrow(groundTruth)
  return(c(result, list(Score = score, Issue = "")))
}))
resultTable <- rbind(resultTable,
  data.table(Name = "Predict_0", Full_Name = "Predict_0", Account = "Predict_0",
      Score = dmcScore(actual = groundTruth$fraud, prediction = 0) / nrow(groundTruth), Issue = ""),
  data.table(Name = "KIT_Top_11", Full_Name = "KIT_Top_11", Account = "KIT_Top_11",
      Score = 0.06312723, Issue = ""),
  data.table(Name = "Top_10", Full_Name = "Top_10", Account = "Top_10",
      Score = 0.06422134, Issue = ""),
  data.table(Name = "Top_3", Full_Name = "Top_3", Account = "Top_3",
      Score = 0.0792177, Issue = ""),
  data.table(Name = "Top_1", Full_Name = "Top_1", Account = "Top_1",
      Score = 0.1030974, Issue = "")
)
resultTable[order(-Score)]
