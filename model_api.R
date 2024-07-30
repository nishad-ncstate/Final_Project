# Load necessary libraries
library(plumber)
library(randomForest)
library(caret)
library(ranger)

# Load the dataset and the best model
data <- read.csv("C:/Users/karen/Downloads/diabetes_binary_health_indicators_BRFSS2015.csv")

# Convert Diabetes_binary to a factor with appropriate levels
data$Diabetes_binary <- factor(data$Diabetes_binary, levels = c(0, 1), labels = c("No", "Yes"))

# Set seed for reproducibility
set.seed(123)

# Split the data
train_index <- createDataPartition(data$Diabetes_binary, p = 0.7, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

# Train the best model using ranger
best_model <- train(Diabetes_binary ~ ., data = train_data, method = "ranger", trControl = trainControl(method = "cv", number = 5, summaryFunction = mnLogLoss, classProbs = TRUE))

# Create a new plumber API
r <- plumb()

#* @apiTitle Diabetes Prediction API

#* Predict Diabetes
#* @param Age Integer. Age of the individual.
#* @param BMI Numeric. Body Mass Index of the individual.
#* @param HighBP Integer. 0 for No, 1 for Yes.
#* @param HighChol Integer. 0 for No, 1 for Yes.
#* @param Smoker Integer. 0 for No, 1 for Yes.
#* @param Stroke Integer. 0 for No, 1 for Yes.
#* @param HeartDiseaseorAttack Integer. 0 for No, 1 for Yes.
#* @param PhysActivity Integer. 0 for No, 1 for Yes.
#* @param Fruits Integer. 0 for No, 1 for Yes.
#* @param Veggies Integer. 0 for No, 1 for Yes.
#* @param HvyAlcoholConsump Integer. 0 for No, 1 for Yes.
#* @param AnyHealthcare Integer. 0 for No, 1 for Yes.
#* @param NoDocbcCost Integer. 0 for No, 1 for Yes.
#* @param GenHlth Integer. 1 (excellent) to 5 (poor).
#* @param MentHlth Integer. Number of days in the past 30 days mental health was not good.
#* @param PhysHlth Integer. Number of days in the past 30 days physical health was not good.
#* @param DiffWalk Integer. 0 for No, 1 for Yes.
#* @param Sex Integer. 0 for Female, 1 for Male.
#* @param Age Numeric. Age of the individual.
#* @param Education Integer. 1 (never attended school) to 6 (graduate school).
#* @param Income Integer. 1 (less than $10,000) to 8 ($75,000 or more).
#* @get /pred
function(Age = 50, BMI = 25, HighBP = 0, HighChol = 0, Smoker = 0, Stroke = 0, HeartDiseaseorAttack = 0, PhysActivity = 1, Fruits = 1, Veggies = 1, HvyAlcoholConsump = 0, AnyHealthcare = 1, NoDocbcCost = 0, GenHlth = 3, MentHlth = 0, PhysHlth = 0, DiffWalk = 0, Sex = 0, Education = 4, Income = 6) {
  new_data <- data.frame(
    Age = as.integer(Age), BMI = as.numeric(BMI), HighBP = as.integer(HighBP), HighChol = as.integer(HighChol), Smoker = as.integer(Smoker), Stroke = as.integer(Stroke),
    HeartDiseaseorAttack = as.integer(HeartDiseaseorAttack), PhysActivity = as.integer(PhysActivity), Fruits = as.integer(Fruits), Veggies = as.integer(Veggies),
    HvyAlcoholConsump = as.integer(HvyAlcoholConsump), AnyHealthcare = as.integer(AnyHealthcare), NoDocbcCost = as.integer(NoDocbcCost), GenHlth = as.integer(GenHlth),
    MentHlth = as.integer(MentHlth), PhysHlth = as.integer(PhysHlth), DiffWalk = as.integer(DiffWalk), Sex = as.integer(Sex), Education = as.integer(Education), Income = as.integer(Income)
  )
  predict(best_model, new_data, type = "prob")[,2]
}

#* Model Info
#* @get /info
function() {
  list(
    name = "Nishad",
    url = "https://nishad-ncstate.github.io/Final_Project"
  )
}

r
