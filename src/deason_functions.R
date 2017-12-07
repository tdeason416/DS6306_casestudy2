library(Hmisc)
library(tidyr)
library(dplyr)

find_percent <- function(df, label_col, num_obs)
    '''
    Find the number of observations based on
    --------
    INPUTS
    df: data.frame
        - dataframe with all catagorical data
    label_col
        -   binary column of interest in df
    num_obs: named.vector
        -   contains all possible values in df with the  correlated number of observations
    --------
    RETURNS
    percent_pos: named.vector
        -   contains the percentage of each value within the dataframe which is associated with the label_column.
    '''
    for(col_val in names(num_obs))
        {
        sub_df <- subset(data_binned, label_col == TRUE)
        colval <- unlist(strsplit(col_value, '&'))
        percent_pos[colval] = \(sum(sub_df[,colval[1]] == colval[2])  / num_obs[col_val])
        }
    return(percent_pos)
    }

find_number_observations <- function(df, sep='&')
    num_obs= c()
    for (col in names(data_binned)){
        if(check_na){
            num_obs[paste(col, 'isna', sep=sep)] = sum(is.na(data[,col])) / 1470
            }
        for (value in unique(data_binned[,col]))
            {
            num_obs[paste(col, value, sep=sep)] = sum(data_binned[,col] == value)
            }
    }
}

make_dummy <- function(df, sep='&'){
    '''
    Convert dataframe with all catagorical data into all boolean dataframe
    --------
    INPUTS
    df: data.frame
        -   Data should all be catagorical.
    sep: str
        -   Character to use as seperator between column and value
    --------
    RETURNS
    dfo: data.frame
        -   all data is bool
    '''
    dfo <- df
    for(col in names(df)){
        for(val in unique(dfo[,col])){
            dfo[, paste(col, val, sep=sep)] = dfo[, col] == val
            }
        dfo = dfo[, names(dfo) != col]
        }
    return(dfo)
    }

find_covariance <- function(df, items, sep){
    '''
    Take a subset of columns in df and find the covariance between them
    ---------
    INPUTS
    df: data.frame
        -   All data inputs must of type bool
    items: data.frame
        -   columns in the dataframe to compare to each other
    sep: str
        -   character to use to seperate columns being compared
    --------
    RETURNS
    covar: named vector
        -   sets of column names seperated by sep
    '''
    covar = c()
    for(col1 in items){
        for(col2 in items){
            if(col1 != col2){
                covar[paste(col1, col2, sep='+')] = sum(df[,col1] == TRUE & df[,col2] == TRUE) / (sum(df[,col1] == TRUE) + .00001)
                }
            }
        items = items[items != col1]
        }
    return(covar)
    }

bin_columns <- function(data, min_size=100, num_splits=10)
    '''
    Convert continous data into discrete catagorical data
    by splitting continous data into equal sized (by number of members) groups.
    --------
    data: data.frame
        -   data frame which contains continous data
    min_size: integer
        -   min number of members in a group (determine split pts). columns with less discrete points then this value will be ignored.
    num_splits
        -   number of times to split continous dataset
    --------
    '''
    {
    types <- sapply(data, class)
    data_binned <- data
    for(col in names(types)){
            if(types[[col]] == 'integer' & length(unique(data[,col])) > num_splits){
            data_binned[col] <- cut2(data[,col], m=min_size, g=num_splits)
            }
        }
    return(data_binned)
    }


# Sequence to build really cool stuff
# bdf <- bin_columns(df)
# num_obs <- find_number_observations(bdf, sep='&')
# find_percent(df)
#
#
#
#
#
