require(xlsx)
#require(psych)
require(leaps)
require(MASS)
require(tidyverse)
require(reshape2)
require(ggplot2)
require(ggmosaic)
require(plyr)
### import data
employee<-read.xlsx('data/CaseStudy2-data.xlsx',sheetIndex = 1)

### Purpose of the Project:

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
employee$AgeGroups <- cut(employee$Age, breaks = 5)

####Build Correlation matrix for all numeric variables
#nnames<-names(Filter(is.numeric,employee))
#lowerCor(employee[,nnames])
####

#Attrition Analysis.

###Run automatic methods for variable selection from the choosen variables.
#install.packages("leaps")

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

# summary(regBest)

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

##<<<<<<< HEAD

#### Probabilities of value given attrition #### 
##=======
    #### Probabilities of Attrition #### 
##>>>>>>> 2c17e703ca3f8f4fc0ec75bbdf0ddb4e93a5b6cc

attrified <- employee[employee$Attrition == 'Yes',]
not.attrified <- employee[employee$Attrition == 'No', ]

Attrition_prop_table <- function(variable_name, data.f){
    # Generates a table containing proportion of responses for both Attrition values. This should allow us to examine values in the context of whether they attrified.
    
    # Generate a table containing variable/Attrition rates
    prop <-prop.table(xtabs(as.formula(paste( '~ ',paste(variable_name, 'Attrition ', sep = ' + '))) , data=data.f))
    
    #Normalize each column to sum to 1.
    prop.app <-apply(prop,2,sum)
    return(melt(sweep(prop, MARGIN=2,prop.app,'/')))
}


EnvSatTest_attrit <- Attrition_prop_table('EnvironmentSatisfaction',employee)
MariStat_attrit <- Attrition_prop_table( 'MaritalStatus',employee)
# Employees that left are most likely to be single.
OverTime_attrit <- Attrition_prop_table( 'OverTime',employee)
JobInvolv_attrit <- Attrition_prop_table( 'JobInvolvement',employee)
JobRole_attrit <- Attrition_prop_table( 'JobRole',employee)
# We have highest relative turnover of Sales Representative. Very few Research Directors leave.

AgeGroup_attrit <- Attrition_prop_table( 'AgeGroups', employee)
# Younger employees are more likely to leave.
table(employee[employee$Age < 26.4,'JobRole']) # Lab Tech, Research Scientist, 
table(employee[employee$Age < 26.4 & employee$Attrition =='Yes','JobRole']) # Sales Rep, Lab Tech, Research Scientist are the jobs most often left.

##<<<<<<< HEAD
#### Plots of variables ####
plot(employee$Attrition,employee$OverTime,main="Attrition vs OverTime",col=c("light blue","pink"))
plot(employee$Attrition,employee$MaritalStatus,main="Attrition vs MaritalStatus")
plot(employee$Attrition,employee$EnvironmentSatisfaction,main="Attrition vs EnvironmentSatisfaction")
plot(employee$Attrition,employee$TotalWorkingYears,main="Attrition vs TotalWorkingYears")
plot(employee$Attrition,employee$Age, main="Attrition vs Age ")
plot(employee$Attrition,employee$JobInvolvement,main="JobInvolvement vs Attrition")
plot(employee$Attrition,employee$JobRole,main="JobRole vs Attrition")

## 100% Stacked Bar chart
ggplot(EnvSatTest_attrit, aes(x=Attrition, y=value, fill= factor(EnvironmentSatisfaction))) + 
    geom_bar(position = "fill",stat = "identity") +
    scale_y_continuous(breaks = c(1,2,3,4)) +
    labs(title = 'Attrition rate by\nEnvironment Satisfaction', y='Proportion of Response') +
    guides(fill=guide_legend(title="Environment \nSatisfaction"))+
    theme(legend.title=element_text(size = 9),plot.title=element_text(hjust=0.5))

##=======
##    >>>>>>> 2c17e703ca3f8f4fc0ec75bbdf0ddb4e93a5b6cc

#### We'll go ahead and create multiple linear regression model to get more evidence to determine which factors imapct Atrrition the most.
#### Build regression model

mylm<-lm(AttritionN ~ OverTimeN + MaritalStatusN + EnvironmentSatisfaction + TotalWorkingYears+ Age + JobInvolvementN + JobRoleN, data = employee)
summary(mylm)

### factors significant are: OverTimeN,MaritalStatusN,EnvironmentSatisfaction,JobInvolvementN,TotalWorkingYears and Age.
### Select top factors that impact attrition the most,plot the data.
#### The top factors are: OverTime,EnvironmentSatisfaction,MaritalStatus, 

## Combine values in the factorss for further analysis.

employee$MaritalStatusR<-as.character(employee$MaritalStatus)
employee$MaritalStatusR[employee$MaritalStatusR!="Single"]<-c("Not Single")
employee$EnvironmentSatisfactionR<-employee$EnvironmentSatisfaction
employee$EnvironmentSatisfactionR[employee$EnvironmentSatisfaction!=1]<-c("Medium or Higher Satisfation")
employee$EnvironmentSatisfactionR[employee$EnvironmentSatisfaction==1]<-c("Low Satisfation")

#### Plots factors

bg<-ggplot(employee, aes(x=OverTime,fill=Attrition))
bg<-bg + geom_bar(position = "fill")
bg<-bg + scale_y_continuous(labels = scales::percent)
bg<-bg + labs(y="Percentage", x="Over Time", title="Attrition vs OverTime")
bg

bg<-ggplot(employee, aes(x=MaritalStatusR,fill=Attrition))
bg<-bg + geom_bar(position = "fill")
bg<-bg + scale_y_continuous(labels = scales::percent)
bg<-bg + labs(y="Percentage", x="MaritalStatus", title="Attrition vs MaritalStatus")
bg

bg<-ggplot(employee, aes(x=EnvironmentSatisfactionR,fill=Attrition))
bg<-bg + geom_bar(position = "fill")
bg<-bg + scale_y_continuous(labels = scales::percent)
bg<-bg + labs(y="Percentage", x="Environment Satisfaction", title="Attrition vs Environment Satisfaction")
bg

#### From the plot, we can get below facts:
#### 1. The first group has the highest turnover rates. They have the following characteristics: Work over time, single.                                
#### 2. The second group has the high turnover rates. They have the following characteristics: Work over time, married, low satisfaction on the work environement.      
#### 3. The third group has the high turnover rates. They have the following characteristics: Single, low satisfaction on the work environement.

bg<-ggplot(employee)
bg<-bg + geom_mosaic(aes( x = product(MaritalStatusR,OverTime,EnvironmentSatisfactionR),
                          fill=Attrition)) 
bg<-bg + theme(axis.text.x=element_text(angle=35, hjust= 1))
bg<-bg + labs(x="Marital Status, Eviroment Satisfaction", title='divider= "hspine"')
bg<-bg + guides(fill=guide_legend(reverse = TRUE))
bg

mosaicplot(~Attrition + OverTime + MaritalStatusR + EnvironmentSatisfactionR, 
           shade = T, data = employee ,
           main = "Emploree attrition related to overtime, marital status and environment satisfaction",
           las = 5,
           border = "chocolate",
           off = 10
)

#Job Role Analysis.
### There are nine job roles in the dataset
levels(employee$JobRole)

### Chose meaningful features of the dataset for Job Role: WorkLifeBalance

### Create subset for Analysis
sub.JRNCW<-employee[,c("NumCompaniesWorked","JobRole","JobRoleN")]
mean.JRNCW<-ddply(employee,~JobRole,summarise,meanNCW=mean(NumCompaniesWorked))

### Build model
lm1<-lm(formula = NumCompaniesWorked ~ JobRole, data = sub.JRNCW)
summary(lm1)

# Research Director and Sales representative shows significant difference in number of companies worked than other roles.
sub.JRNCW$JobRoleR<-as.character(sub.JRNCW$JobRole)
sub.JRNCW$JobRoleR[sub.JRNCW$JobRoleR!="Research Director"]<-c("Non Research Director")

sub.JRNCW$JobRoleS<-as.character(sub.JRNCW$JobRole)
sub.JRNCW$JobRoleS[sub.JRNCW$JobRoleS!="Sales Representative"]<-c("Non Sales")

###Significant evidence shows that the mean number of companies that a Research Director had ever worked is greater than other roles. 
###p-vlue=0.00017 at significant level alpha=0.05
### 95% confidence level of how many more companies a Reseach Director had every worked is 0.5 to 1.6.
aov1<-aov(NumCompaniesWorked~JobRoleR,data = sub.JRNCW)
summary(aov1)
confint(aov1)
bg<-ggplot(sub.JRNCW, aes())
bg<-bg + geom_bar(aes(x=JobRoleR, y=NumCompaniesWorked, fill = JobRoleR), 
                  position = "dodge", stat = "summary", fun.y = "mean")
bg


###Significant evidence shows that the mean number of companies that a Sales Representative had ever worked is less than other roles. 
### p-vlue=<0.0001. at significant level alpha=0.05
### 95% confidence level shows: The companies that a Sales Representative have ever worked is 0.5 to 1.7 less than other groups of roles.
aov2<-aov(NumCompaniesWorked~JobRoleS,data = sub.JRNCW)
summary(aov2)
confint(aov2)
bg<-ggplot(sub.JRNCW, aes())
bg<-bg + geom_bar(aes(x=JobRoleS, y=NumCompaniesWorked, fill = JobRoleS), 
                  position = "dodge", stat = "summary", fun.y = "mean")
bg

## *Conclusion:* 
### From the analysis, Sales Representative workes less companies than other groups of roles and Research Director works more companies than other group of roles.
### But this results might be impacted by confound variances. Such as , Sales Representative's Age, working years and so on. Further analysis need to proceed on the test to determine confound variables.