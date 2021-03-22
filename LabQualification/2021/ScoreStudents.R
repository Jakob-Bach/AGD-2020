# Scores multiple submissions of students, provided in the ILIAS folder layout
# (one dir per student named "<<Name>>_<<uxxxx>>_<<some number>>").
# In each student dir, there might be multiple prediction files (e.g., if some of them need manual fixing).
# You might need to adapt or create "GROUND_TRUTH_FILE" and "SUBMISSION_BASE_PATH"
# before running the script.

library(data.table)

GROUND_TRUTH_FILE <- "data/test_labels.csv"
SUBMISSION_BASE_PATH <- "../../../../DS_Praktikum_2021/Quali_submissions"

# Computes the DMC score.
mcc <- function(actual, prediction) {
  classLabels <- unique(actual)
  positive <- classLabels[1] # +/- is arbitrary because symmetry of MCC
  negative <- classLabels[2]
  tp <- 1.0 * sum(actual == positive & prediction == positive) # 1.0 prevents integer overflow
  tn <- 1.0 * sum(actual == negative & prediction == negative)
  fp <- 1.0 * sum(actual == negative & prediction == positive)
  fn <- 1.0 * sum(actual == positive & prediction == negative)
  return((tp * tn - fp * fn) / sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn)))
}

groundTruth <- fread(GROUND_TRUTH_FILE, quote = "")
predictionFiles <- list.files(SUBMISSION_BASE_PATH, pattern = "_prediction.csv",
                              full.names = TRUE, recursive = TRUE)
studentDirs <- list.dirs(SUBMISSION_BASE_PATH, full.names = FALSE)[-1] # minus original dir
accountNames <- gsub("_", "", regmatches(studentDirs, regexpr("_u[a-z]{4}", studentDirs)))
fullNames <- gsub("_u.*", "", studentDirs)
resultTable <- rbindlist(lapply(predictionFiles, function(predictionFileName) {
  # Grep meta-data; slightly complicated, because some info is part of dir name,
  # but there might be multiple prediction files per dir
  studentName <- gsub("_prediction.csv", "", basename(predictionFileName))
  filePathSplit <- strsplit(predictionFileName, "/")[[1]]
  dirIdx <- which(grepl(filePathSplit[length(filePathSplit) - 1], studentDirs))
  language <- "Other"
  if (length(list.files(dirname(predictionFileName), pattern = "\\.Rmd")) > 0) {
    language <- "R"
  }
  if (length(list.files(dirname(predictionFileName), pattern = "\\.ipynb")) > 0) {
    language <- "Python"
  }
  isFixed <- grepl("-fixed", predictionFileName) # manually edited by Jakob
  result <- list(Name = studentName, Full_Name = fullNames[dirIdx], Account = accountNames[dirIdx],
                 Language = language, isFixed = isFixed)
  # Read prediction
  prediction <- fread(predictionFileName, quote = "", header = TRUE)
  # Check validity of submission
  if (nrow(prediction) != nrow(groundTruth)) {
     return(c(result, list(Score = NA, Issue = "Number of observations wrong.")))
  }
  if (ncol(prediction) != ncol(groundTruth)) {
    return(c(result, list(Score = NA, Issue = "Number of columns wrong (e.g., row names).")))
  }
  if (any(startsWith(colnames(prediction), "\""))) {
    return(c(result, list(Score = NA, Issue = "Column name quoted.")))
  }
  if (colnames(prediction) != colnames(groundTruth)) {
    return(c(result, list(Score = NA, Issue = "Column name wrong.")))
  }
  if (anyNA(prediction$target) | any(prediction$target == "")) {
    return(c(result, list(Score = NA, Issue = "Some empty predictions.")))
  }
  if (any(prediction$target != "stable" & prediction$target != "unstable")) {
    return(c(result, list(Score = NA, Issue = "Additional class labels.")))
  }
  score <- mcc(actual = groundTruth$target, prediction = prediction$target)
  if (is.nan(score)) {
    score <- 0
  }
  return(c(result, list(Score = score, Issue = "")))
}))
resultTable <- rbind(resultTable)
print(resultTable[order(-Score)])
