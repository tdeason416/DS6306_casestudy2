library(Hmisc)
library(tidyr)
library(dplyr)
library(stringr)

find_percent <- function(df, label_col, num_obs, sep='&'){
    ##find the ratio of a certian value which includes the label
    ##--------
    ##INPUTS
    ##df: data.frame
    ##    - dataframe with all catagorical data
    ##label_col
    ##    -   binary column of interest in df
    ##num_obs: named.vector
    ##     -   contains all possible values in df with the  correlated number of observations
    ## --------
    ## RETURNS
    ## percent_pos: named.vector
    ##     -   contains the percentage of each value within the dataframe which is associated with the label_column.
    percent_pos <- c()
    sub <- df[,label_col] == TRUE
    sub_df <- df[sub,]
    for(col_val in names(num_obs)){
        colval <- unlist(strsplit(col_val, sep))
        percent_pos[col_val] = ((sum(sub_df[,colval[1]] == colval[2]) + .0001))  / (num_obs[col_val] + .0001)
        }
    return(percent_pos)
    }

find_number_observations <- function(df, sep='&', check_na=FALSE){
    num_obs= c()
    for (col in names(data_binned)){
        if(check_na){
            num_obs[paste(col, 'isna', sep=sep)] = sum(is.na(data[,col])) / dim(df)[1]
            }
        for (value in unique(data_binned[,col]))
            {
            num_obs[paste(col, value, sep=sep)] = sum(data_binned[,col] == value)
            }
    }
    return(num_obs)
}

make_dummy <- function(df, sep='&'){
    # Convert dataframe with all catagorical data into all boolean dataframe
    # --------
    # INPUTS
    # df: data.frame
    #     -   Data should all be catagorical.
    # sep: str
    #     -   Character to use as seperator between column and value
    # --------
    # RETURNS
    # dfo: data.frame
    #     -   all data is bool
    dfo <- df
    for(col in names(df)){
        for(val in unique(dfo[,col])){
            dfo[, paste(str_trim(col), str_trim(val), sep=sep)] = dfo[, col] == val
            }
        dfo = dfo[, names(dfo) != col]
        }
    return(dfo)
    }

find_covariance <- function(df, items, sep='+'){
    # Take a subset of columns in df and find the covariance between them
    # ---------
    # INPUTS
    # df: data.frame
    #     -   All data inputs must of type bool
    # items: data.frame
    #     -   columns in the dataframe to compare to each other
    # sep: str
    #     -   character to use to seperate columns being compared
    # --------
    # RETURNS
    # covar: named vector
    #     -   sets of column names seperated by sep with duplicates and self correalations removed
    covar = c()
    for(col1 in items){
        for(col2 in items){
            if(col1 != col2){
                covar[paste(str_trim(col1), str_trim(col2), sep='+')] = (sum(df[,col1] == TRUE & df[,col2] == TRUE) + .00001) / (max(c(sum(df[,col1] == TRUE), sum(df[,col2] == TRUE))) + .00001)
                }
            }
        items = items[items != col1]
        }
        covar <- covar[order(-covar)]
        return(covar[c(TRUE, FALSE)])
    }

bin_columns <- function(data, min_size=100, num_splits){
    # Convert continous data into discrete catagorical data
    # by splitting continous data into equal sized (by number of members) groups.
    # --------
    # data: data.frame
    #     -   data frame which contains continous data
    # min_size: integer
    #     -   min number of members in a group (determine split pts). columns with less discrete points then this value will be ignored.
    # num_splits
    #     -   number of times to split continous dataset
    # --------
    types <- sapply(data, class)
    data_binned <- data
    for(col in names(types)){
        if(types[[col]] == 'integer' & length(unique(data[,col])) > num_splits){
            data_binned[col] <- cut2(data[,col], m=min_size, g=num_splits)
            data_binned[,col] = sapply(data_binned[,col], toString)
            }
        else{
            data_binned[,col] = sapply(data[,col], toString)}
        }
    names(data_binned) <- sapply(names(data_binned), str_trim)
    return(data_binned)
    }


check_label_corelation <- function(df, label, dsep='&', sd_ratio=1){
## function to generate top contributing variables to a specific label
##--------
##INPUTS
##df: data.frame
##  -   contains all catagorical variables, label col must be T/F
##label: string
##  -   name of label column
##sep: str
##  -   character to use in seperating dummy values from col name
##--------
##RETURNS
## coors: named_vector
##  -   contains coorelation rate for each value in the df
    all_pos <- sum(df[,label] == TRUE) / dim(df)[1]
    print(all_pos)
    num_obs <- find_number_observations(df, sep=dsep)
    percent_pos <- find_percent(df, label, num_obs, sep=dsep)
    label_frame <- data.frame(percent_pos, num_obs)
    label_frame[,'ratio_delta'] <- label_frame$percent_pos - all_pos
    not_label <- (rownames(label_frame) != paste(label, 'TRUE', sep=dsep) & rownames(label_frame) != paste(label, 'FALSE', sep=dsep)) 
    label_frame <- label_frame[not_label,]
    one_dev <- sd(label_frame[,'ratio_delta']) * sd_ratio
    label_infl <- label_frame[abs(label_frame[,'ratio_delta']) > one_dev,]
    return(label_infl[order(-label_infl$ratio_delta),])
}