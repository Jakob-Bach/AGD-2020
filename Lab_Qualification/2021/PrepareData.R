# Prepares the train and test data for the 2021 qualification task.
# You don't need to adapt any of the constants below or install any package,
# just run the script.

DATA_URL <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00471/Data_for_UCI_named.csv"
DATA_DIR <- "data/"
DATASET_NAME <- "DSGC"
DATA_PATH <- paste0(DATA_DIR, DATASET_NAME, ".csv")
TARGET <- "stabf"
TRAIN_FRACTION <- 0.8

# Download and save full dataset
download.file(DATA_URL, destfile = DATA_PATH)
dataset <- read.csv(DATA_PATH)  # download contains empty lines, so read + save again
dataset$stab <- NULL # remove continuous target
write.csv(dataset, file = DATA_PATH, row.names = FALSE)

# Create + save splits
set.seed(25)
trainIdxPerClass <- lapply(unique(dataset[[TARGET]]), function(classLab) {
  classIdx <- which(dataset[[TARGET]] == classLab)
  sample(classIdx, size = round(TRAIN_FRACTION * length(classIdx)), replace = FALSE)
})
trainIdx <- sort(unlist(trainIdxPerClass))
testIdx <- c(1:nrow(dataset))[-trainIdx] # use all indices except trainIdx
trainData <- dataset[trainIdx, ]
testData <- dataset[testIdx, ]
write.table(trainData[, colnames(trainData) != TARGET], file = paste0(DATA_DIR, "train_values.csv"),
            row.names = FALSE, quote = FALSE, sep = "|")
write.table(data.frame(target = trainData[[TARGET]]), file = paste0(DATA_DIR, "train_labels.csv"),
            row.names = FALSE, quote = FALSE, sep = "|")
write.table(testData[, colnames(trainData) != TARGET], file = paste0(DATA_DIR, "test_values.csv"),
            row.names = FALSE, quote = FALSE, sep = "|")
write.table(data.frame(target = testData[[TARGET]]), file = paste0(DATA_DIR, "test_labels.csv"),
            row.names = FALSE, quote = FALSE, sep = "|")
