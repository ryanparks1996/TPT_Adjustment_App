# Load in libraries
library(readxl)
library(dplyr)


# FUNCTION TO PARSE DATA AND REMOVE EXTRA HEADERS ------------------------------
# file: path to an excel file
# desired_col: vector of some or all of the desired column names
# rm_sums_row: will remove the last row (use when last row is a grand total)
# rm_sums_col: will remove the last columns (use when last column is a grand total)

removeExtraHeaders <- function(file, 
                               desired_col, 
                               rm_sums_row = FALSE,
                               rm_sums_col = FALSE) {
  # Read first few rows to check for correct header
  data <- read_excel(file, n_max = 11) 
  
  # short loop to find what row the col_names are on
  skip <- 1
  desired_col_name <- rep(" ", ncol(data))
  
  for (row in 1:10) {
    if (any(data[row, ] %in% desired_col)) {
      skip <- row + 1 
      desired_col_name <- data[row, ] %>%
        as.character() # Convert to character vector
      break # End the loop. We have found the proper header
    }
    # Return error if no match is found
    if (row == 10) { # row = 10 only if no row including the 10th did not match
      stop("No match was found. Unable to remove extra headers.")
    }
  }
  
  # Re-read the data but now filtering out the extra headers
  data_corrected <- read_excel(file,
                               skip = skip,
                               col_names = desired_col_name)
  
  # Get number of rows and columns in corrected data frame
  n <- nrow(data_corrected)
  m <- ncol(data_corrected)
  
  # If desired, remove last row from data frame
  if (rm_sums_row) {
    data_corrected <- data_corrected[-n, ]
  }
  
  # If desired, remove last column from data frame
  if (rm_sums_col) {
    data_corrected <- data_corrected[ , -m]
  }
  
  # Return data frame with the proper header
  return(data_corrected)
}
##----------------------------------------------------------------------------##

# FUNCTION TO CREATE CUSTOM SUMAMRY STATISTICS TABLE
# data: data frame of weekly tpt report
tpt_summary <- function(data) {
  # Total games
  total_games <- nrow(data)
  # Total non-redemption games
  total_by_redemption <- data %>%
    group_by(TicketProfile) %>%
    summarize(num_of_games = n_distinct(Game))
  # Number of games above 6 TPT
  n_tpt_above_6 <- data %>%
    filter(TPT > 6) %>%
    summarize(n_distinct(Game)) %>%
    as.numeric()
  # Number of redemption games below 2 TPT
  n_tpt_below_2 <- data %>%
    filter((TicketProfile == "Redemption") & (TPT < 2)) %>%
    summarize(n_distinct(Game)) %>%
    as.numeric()
  # Overall TPT
  tpt_all <- sum(data$TICKETS) / sum(data$`Total Plays`)

  
  
  row_names <- c("Total Games:", 
            "Redemption Games:", 
            "Non-Redemption Games:",
            "Games (TPT>6):",
            "Games (TPT<2):",
            "Overall TPT:")
  
  column <- c(total_games, 
            as.numeric(total_by_redemption[2, 2]), 
            as.numeric(total_by_redemption[1, 2]),
            n_tpt_above_6,
            n_tpt_below_2,
            tpt_all)
  
  tpt_table <- data.frame("values" = column,
                          row.names = row_names)
  return(tpt_table)
}
##----------------------------------------------------------------------------##


