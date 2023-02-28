# Exercises for Big Data Analytics, winter semester 2020/2021

This repo contains the exercises for the lecture ["Big Data Analytics"](http://dbis.ipd.kit.edu/english/2944.php) ("Analysetechniken für große Datenbestände") at KIT in winter semester 2020/2021.
I re-structured the exercises as part of the ["Baden-Württemberg-Zertifikat für Hochschuldidaktik"](https://www.hdz-bawue.de/home-en-gb/).
`Uebungskonzept.pdf` introduces the exercise concept.
While the previous exercise concept focused on programming tasks, the new one uses a combination of:

- programming tasks
- (theory-oriented) online tests (for the learning management system `ILIAS`; I provide exports here)
- (interactive, Q&A-based) exercise sessions (I summarized the discussions as presentations)

Further, there were two surveys (again on `ILIAS`) to assess the satisfaction of the students.

Apart from the solutions to the programming exercises, materials are in German.
For English materials, see the [following year's course](https://github.com/Jakob-Bach/DS-Exercises-2021) (note that the actual tasks differ more or less).

## Programming Exercise Structure

The goal of the exercises is to apply basic data-mining techniques to small toy datasets.
The solutions use the programming language R, version `4.0.3`, and the recent (end of 2020 / beginning of 2021) versions of all required packages.
Solutions are available as notebooks, in both `.Rmd` as well as `.html` format.

- Exercise sheet 1:
  - R basics (including descriptive statistics and plots)
  - Statistical tests
- Exercise sheet 2:
  - Entropy
  - PCA
- Exercise sheet 3:
  - Decision trees
  - Evaluation of classifiers
- Exercise sheet 4:
  - Association rules
- Exercise sheet 5:
  - Clustering
  - Outlier detection
- Exercise sheet 6:
  - Lab qualification task 2021

## Lab Qualification

Since the beginning of 2019, aspiring participants of the practical course in the following summer semester have to solve a qualification task first.

- Qualification task 2020: Data Mining Cup 2019
  - Download the data from the [DMC website](https://www.data-mining-cup.com/reviews/dmc-2019/), un-zip it and place it in a folder called `data/`.
  - Create a simple valid submission with `CreateDemoSubmission-xgboost.R`.
  - Score a folder of ILIAS submissions with `ScoreStudents.R` (i.e., folder containing sub-folders named like `<<Name>>_<<uxxxx>>_<<some number>>`).
- Qualification task 2021: Predict grid stability with the [DSGC dataset](https://archive.ics.uci.edu/ml/datasets/Electrical+Grid+Stability+Simulated+Data+)
  - Prepare train-test split of dataset with `PrepareData.R` (also downloads data from UCI repo).
  - Create a simple valid submission with `CreateDemoSubmission-rpart.R` or `CreateDemoSubmission-xgboost.R`.
  - Score a folder of ILIAS submissions with `ScoreStudents.R` (i.e., folder containing sub-folders named like `<<Name>>_<<uxxxx>>_<<some number>>`).
