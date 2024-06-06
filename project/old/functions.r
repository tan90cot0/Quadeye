date_difference <- function(date1, date2) {
    # Extract year, month, and day from the first date string
    year1 <- as.numeric(substr(date1, 1, 4))
    month1 <- as.numeric(substr(date1, 5, 6))
    day1 <- as.numeric(substr(date1, 7, 8))

    # Extract year, month, and day from the second date string
    year2 <- as.numeric(substr(date2, 1, 4))
    month2 <- as.numeric(substr(date2, 5, 6))
    day2 <- as.numeric(substr(date2, 7, 8))

    # Create Date objects manually
    date1 <- as.Date(paste(year1, month1, day1, sep="-"), format="%Y-%m-%d")
    date2 <- as.Date(paste(year2, month2, day2, sep="-"), format="%Y-%m-%d")

    # Calculate the difference in days
    difference <- as.numeric(difftime(date2, date1, units = "days"))

    return(difference)
}

get_new_df <- function(element, expiry_mapping){
    combined_data <- data.frame(
        time_sec = numeric(),
        date = character(),
        symbol = character(),
        quote.mid = numeric(),
        quote.f_mid = numeric(),
        volume = numeric(),
        rate = numeric(),
        stringsAsFactors = FALSE
    )

    # Iterate through unique mapped symbols
    for (unique_symbol in unique(element$mapped_symbol)) {
        # Filter rows with the same mapping
        rows <- element[element$mapped_symbol == unique_symbol,]
        s = 1
        f = 2
        if (nchar(rows$symbol[1]) > nchar(rows$symbol[2])) {
            s = 2
            f = 1
        }

        if (rows$quote.mid[f] > 0 && rows$quote.mid[s] > 0) {
            numerator <- 365*(rows$quote.mid[f] - rows$quote.mid[s])
            time_to_expiry <- date_difference(rows$date[1], expiry_mapping[rows$symbol[f]])
            denominator <- time_to_expiry*(0.1*rows$quote.mid[f] + rows$quote.mid[s])
            rate_value <- numerator / denominator
            rate_value <- rate_value * 100
        } else {
            rate_value <- 0
        }

        if(rows$quote.valid[s]==1 && rows$quote.valid[f]==1){
            new_row <- data.frame(
                time_sec = rows$time_sec[1],
                date = rows$date[1],
                symbol = unique_symbol,
                quote.mid = rows$quote.mid[s],
                quote.f_mid = rows$quote.mid[f],
                volume = min(rows$quote.bidSz[s], rows$quote.bidSz[f], rows$quote.askSz[s], rows$quote.askSz[f]),
                rate = rate_value,
                stringsAsFactors = FALSE
            )
            combined_data <- rbind(combined_data, new_row)
        }
    }
    combined_data <- combined_data[order(combined_data$symbol), ]
    return (combined_data)
}

get_data <- function(month) {
    if(month==1){
        month1 <- character()
        mapping_month1 <- character()
        directory1 = '/home/aryand2024/extracted/month1/'
        for (i in 1:13) {
            month1 <- c(month1, sprintf("202403%02d.timercapture.csv", i))
            mapping_month1 <- c(mapping_month1, sprintf("202403%02d.univ.log", i))
        }
        return(list(month = month1, mapping_month = mapping_month1, directory = directory1))
    } else if(month==2){
        month2 <- character()
        mapping_month2 <- character()
        directory2 = '/home/aryand2024/extracted/month2/'
        for (i in 14:28) {
            month2 <- c(month2, sprintf("202403%02d.timercapture.csv", i))
            mapping_month2 <- c(mapping_month2, sprintf("202403%02d.univ.log", i))
        }
        for (i in 1:17) {
            month2 <- c(month2, sprintf("202404%02d.timercapture.csv", i))
            mapping_month2 <- c(mapping_month2, sprintf("202404%02d.univ.log", i))
        }
        return(list(month = month2, mapping_month = mapping_month2, directory = directory2))
    } else if(month==3){
        month3 <- character()
        mapping_month3 <- character()
        directory3 = '/home/aryand2024/extracted/month3/'
        for (i in 18:30) {
            month3 <- c(month3, sprintf("202404%02d.timercapture.csv", i))
            mapping_month3 <- c(mapping_month3, sprintf("202404%02d.univ.log", i))
        }
        for (i in 1:15) {
            month3 <- c(month3, sprintf("202405%02d.timercapture.csv", i))
            mapping_month3 <- c(mapping_month3, sprintf("202405%02d.univ.log", i))
        }
        return(list(month = month3, mapping_month = mapping_month3, directory = directory3))
    } else if(month==4){
        month4 <- character()
        mapping_month4 <- character()
        directory4 = '/home/aryand2024/extracted/month4/'
        for (i in 16:31) {
            month4 <- c(month4, sprintf("202405%02d.timercapture.csv", i))
            mapping_month4 <- c(mapping_month4, sprintf("202405%02d.univ.log", i))
        }
        return(list(month = month4, mapping_month = mapping_month4, directory = directory4))
    }
  return(list(month = character(), mapping_month = character(), directory = character()))
}

get_grouped_data <- function(data, underlying_mapping){
    data$time_sec <- ifelse(nchar(data$time) == 9,
                as.numeric(substr(data$time, 1, 2)) * 3600 +
                as.numeric(substr(data$time, 3, 4)) * 60 +
                as.numeric(substr(data$time, 5, 6)) +
                as.numeric(substr(data$time, 7, 9)) / 1000,

                as.numeric(substr(data$time, 1, 1)) * 3600 +
                as.numeric(substr(data$time, 2, 3)) * 60 +
                as.numeric(substr(data$time, 4, 5)) +
                as.numeric(substr(data$time, 6, 8)) / 1000)

    data <- data[, c("time_sec", "time", "date", "symbol", "quote.mid", "quote.bidSz", "quote.askSz", "quote.valid")]
    data <- subset(data, time_sec >= 37800 & time_sec <= 60600)
    data$mapped_symbol = underlying_mapping[data$symbol]
    data$group_key <- paste(data$time)
    grouped_data <- split(data, data$group_key)
    return(grouped_data)
}

get_mapping_data <- function(file){
    underlying_mapping <- c()
    expiry_mapping <- c()
    for (i in 1:nrow(file)) {
        underlying_mapping[file$symbol[i]] <- file$underlying_symbol[i]
        expiry_mapping[file$symbol[i]] <- file$expiry[i]
    }
    return (list(underlying_mapping = underlying_mapping, expiry_mapping = expiry_mapping))
}

get_position <- function(current_instant, upper_thresholds, lower_thresholds){
    positions = rep(0, 16)
    for (i in 1:nrow(current_instant)) {
        row <- current_instant[i, ]
        if (row$rate > upper_thresholds[row$symbol]) {
            positions[i] = row$volume
        }
        if (row$rate < lower_thresholds[row$symbol]) {
            positions[i] = -row$volume
        }
    }
    return(positions)
}