
### import data
library(xlsx)
employee<-read.xlsx("data\\CaseStudy2-data.xlsx",sheetIndex = 1)

### Initial Data Exploration

#### Check for NAs and Nulls
unlist(lapply(employee, function(x) any(is.na(x))))
unlist(lapply(employee, function(x) any(is.null(x))))

####Drop irrelevant columns
employee<-employee[,!(names(employee) %in% c("Over18","EmployeeCount","StandardHours"))]

####Check factor column
ename<-names(employee)
fnames<-names(Filter(is.factor, employee))

####Add numeric columns for factor columns for building correlation matric and regression model

employee$BusinessTravelN<-as.numeric(employee$BusinessTravel)
employee$OverTimeN<-as.numeric(employee$OverTime)
employee$DepartmentN<-as.numeric(employee$Department)
employee$EducationFieldN<-as.numeric(employee$EducationField)
employee$GenderN<-as.numeric(employee$Gender)
employee$OverTimeN<-as.numeric(employee$OverTime)
employee$MaritalStatusN<-as.numeric(employee$MaritalStatus)
employee$JobInvolvementN<-as.numeric(employee$JobInvolvement)
employee$JobRoleN<-as.numeric(employee$JobRole)
employee$AttritionN<-as.numeric(employee$Attrition)

####Build Correlation matrix for all numeric variables
library(psych)
nnames<-names(Filter(is.numeric,employee))
lowerCor(employee[,nnames])
####

###Run automatic methods for variable selection from the choosen variables.
#install.packages("leaps")
library(leaps)
library(MASS)
regBest<- regsubsets(Attrition ~ Age + BusinessTravel + DailyRate +Department  + DistanceFromHome + 
                     EducationField + JobLevel+ JobRole +JobSatisfaction +MaritalStatus +
                     MonthlyIncome + NumCompaniesWorked + OverTime + TotalWorkingYears + 
                     TrainingTimesLastYear + YearsAtCompany + YearsInCurrentRole +
                     YearsSinceLastPromotion + YearsWithCurrManager
                    ## Variables Need further inspection 
                    + EmployeeNumber + EnvironmentSatisfaction + StockOptionLevel
                    + StockOptionLevel + YearsSinceLastPromotion 
                    + Education + Gender + HourlyRate + JobInvolvement
                    + MonthlyRate + PerformanceRating + RelationshipSatisfaction
                    + WorkLifeBalance
                    ## Variables unnessesary
                    ## + Over18 + EmployeeCount + StandardHours
                    ,
                  data = employee, nvmax = 5) 
##summary(regBest)
plot(regBest,col = "brown",main = "Variables chosen by best selection model")
## From the best selection model,top 5 Variables impacting Attrition the most are: 
## OverTime(Yes),MaritalStatus(Single),TotalWorkingYears,EnvironmentSatisfaction,JobInvolvement

regBack<- regsubsets(Attrition ~ Age + BusinessTravel + DailyRate +Department  + DistanceFromHome + 
                       EducationField + JobLevel+ JobRole +JobSatisfaction +MaritalStatus +
                       MonthlyIncome + NumCompaniesWorked + OverTime + TotalWorkingYears + 
                       TrainingTimesLastYear + YearsAtCompany + YearsInCurrentRole +
                       YearsSinceLastPromotion + YearsWithCurrManager
                     ## Variables Need further inspection 
                     + EmployeeNumber + EnvironmentSatisfaction + StockOptionLevel
                     + StockOptionLevel + YearsSinceLastPromotion
                     + Education + Gender + HourlyRate + JobInvolvement
                     + MonthlyRate + PerformanceRating + RelationshipSatisfaction
                     + WorkLifeBalance
                     ## Variables unnessesary
                     ## + Over18 + EmployeeCount + StandardHours 
                     ,
                     data = employee, nvmax = 5, method = "backward") 
#summary(regBack)
plot(regBack,col = "brown",main = "Variables chosen by backward selection model")
## From the backward selection model,top 5 Variables impacting Attrition the most are: 
## OverTime(Yes),MaritalStatus(Single), Age,EnvironmentSatisfaction,JobRole(Sales)

## We would choose OverTime, MaritalStatus, EnvironmentSatisfaction, TotalWorkingYears, Age, JobInvolvement and JobRole for further analysis.

#### Plots of variables
plot(employee$Attrition,employee$OverTime,main="Attrition vs OverTime",col=c("light blue","pink"))
plot(employee$Attrition,employee$MaritalStatus,main="Attrition vs MaritalStatus")
plot(employee$Attrition,employee$EnvironmentSatisfaction,main="Attrition vs EnvironmentSatisfaction")
plot(employee$Attrition,employee$TotalWorkingYears,main="Attrition vs TotalWorkingYears")
plot(employee$Attrition,employee$Age, main="Attrition vs Age ")
plot(employee$Attrition,employee$JobInvolvement,main="JobInvolvement vs Attrition")
plot(employee$Attrition,employee$JobRole,main="JobRole vs Attrition")

#### From the plots We can easliy see correlations between Attirtions and all these variables except for JobInvolvement.
#### We'll go ahead and create multipul linear regression model to get more evidence to determine which factors imapct Atrrition the most.
#### Build regression model


mylm<-lm(AttritionN ~ OverTimeN + MaritalStatusN + EnvironmentSatisfaction + TotalWorkingYears+ Age + JobInvolvementN + JobRoleN, data = employee)
summary(mylm)

### factors significant are: OverTimeN,MaritalStatusN,EnvironmentSatisfaction,JobInvolvementN,TotalWorkingYears and Age.
### Select top three factors that impact atrrition the most,plot the data.
#### The top three factors are: OverTime,EnvironmentSatisfaction,MaritalStatus

#### From the plot, we can get below facts:
#### 1. The first group has the highest turnover rates. They have the following characteristics: Work over time, single.                                
#### 2. The second group has the high turnover rates. They have the following characteristics: Work over time, married, low satisfaction on the work environement.      
#### 3. The third group has the high turnover rates. They have the following characteristics: Single, low satisfaction on the work environement.

mosaicplot(~Attrition + OverTime + MaritalStatus + EnvironmentSatisfaction, 
           shade = T, data = employee ,
           main = "Emploree attrition related to overtime, marital status and environment satisfaction",
           las = 5,
           border = "chocolate",
           off = 10
)
