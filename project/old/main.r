source("functions.R")
library(data.table)
options(scipen = 999)

MAX_GROSS = 400000000
# MAX_GROSS = 100000000

result <- get_data(1)
month = result$month
mapping_month = result$mapping_month
directory = result$directory

lower_thresholds <- c()
upper_thresholds <- c()
lower_thresholds["B3SA3_BOVESPA"] = 9.3
lower_thresholds["BBAS3_BOVESPA"] = 9.3
lower_thresholds["BBDC4_BOVESPA"] = 9.5
lower_thresholds["CSNA3_BOVESPA"] = 9.1
lower_thresholds["GGBR4_BOVESPA"] = 9.1
lower_thresholds["HYPE3_BOVESPA"] = 8.8
lower_thresholds["ITSA4_BOVESPA"] = 9.3
lower_thresholds["ITUB4_BOVESPA"] = 9.2
lower_thresholds["JBSS3_BOVESPA"] = 9.33
lower_thresholds["MGLU3_BOVESPA"] = -100
lower_thresholds["NTCO3_BOVESPA"] = 9.4
lower_thresholds["PETR4_BOVESPA"] = 9.25
lower_thresholds["RENT3_BOVESPA"] = 9.05
lower_thresholds["USIM5_BOVESPA"] = 8.95
lower_thresholds["VALE3_BOVESPA"] = 9.35
lower_thresholds["WEGE3_BOVESPA"] = 9.1

upper_thresholds["B3SA3_BOVESPA"] = 10
upper_thresholds["BBAS3_BOVESPA"] = 9.8
upper_thresholds["BBDC4_BOVESPA"] = 10
upper_thresholds["CSNA3_BOVESPA"] = 9.85
upper_thresholds["GGBR4_BOVESPA"] = 9.7
upper_thresholds["HYPE3_BOVESPA"] = 9.2
upper_thresholds["ITSA4_BOVESPA"] = 10.05
upper_thresholds["ITUB4_BOVESPA"] = 9.8
upper_thresholds["JBSS3_BOVESPA"] = 9.9
upper_thresholds["MGLU3_BOVESPA"] = 100
upper_thresholds["NTCO3_BOVESPA"] = 10.3
upper_thresholds["PETR4_BOVESPA"] = 9.75
upper_thresholds["RENT3_BOVESPA"] = 9.6
upper_thresholds["USIM5_BOVESPA"] = 9.6
upper_thresholds["VALE3_BOVESPA"] = 9.9
upper_thresholds["WEGE3_BOVESPA"] = 9.7

lower_thresholds["B3SA3_BOVESPA"] = 5
lower_thresholds["BBAS3_BOVESPA"] = 5
lower_thresholds["BBDC4_BOVESPA"] = 5
lower_thresholds["CSNA3_BOVESPA"] = 5
lower_thresholds["GGBR4_BOVESPA"] = 5
lower_thresholds["HYPE3_BOVESPA"] = 5
lower_thresholds["ITSA4_BOVESPA"] = 5
lower_thresholds["ITUB4_BOVESPA"] = 5
lower_thresholds["JBSS3_BOVESPA"] = 5
lower_thresholds["MGLU3_BOVESPA"] = -100
lower_thresholds["NTCO3_BOVESPA"] = 5
lower_thresholds["PETR4_BOVESPA"] = 5
lower_thresholds["RENT3_BOVESPA"] = 5
lower_thresholds["USIM5_BOVESPA"] = 5
lower_thresholds["VALE3_BOVESPA"] = 5
lower_thresholds["WEGE3_BOVESPA"] = 5

upper_thresholds["B3SA3_BOVESPA"] = 10
upper_thresholds["BBAS3_BOVESPA"] = 10
upper_thresholds["BBDC4_BOVESPA"] = 10
upper_thresholds["CSNA3_BOVESPA"] = 10
upper_thresholds["GGBR4_BOVESPA"] = 10
upper_thresholds["HYPE3_BOVESPA"] = 10
upper_thresholds["ITSA4_BOVESPA"] = 10
upper_thresholds["ITUB4_BOVESPA"] = 10
upper_thresholds["JBSS3_BOVESPA"] = 10
upper_thresholds["MGLU3_BOVESPA"] = 100
upper_thresholds["NTCO3_BOVESPA"] = 10
upper_thresholds["PETR4_BOVESPA"] = 10
upper_thresholds["RENT3_BOVESPA"] = 10
upper_thresholds["USIM5_BOVESPA"] = 10
upper_thresholds["VALE3_BOVESPA"] = 10
upper_thresholds["WEGE3_BOVESPA"] = 10

gross = 0
position <- rep(0, 16)
avg_price <- rep(0, 16)
avg_fut_price <- rep(0, 16)
profit = 0

calc_gross <- function(position, current_instant){
    gross = 0
    for(k in 1:16){
        gross = gross + abs(position[k]) * (current_instant$quote.mid[k] + 0.1 * current_instant$quote.f_mid[k])
    }
    return(gross)
}

get_profits <- function(new_position, position, current_instant, avg_price, avg_fut_price, total_profit){
    # if -ve position at 15 min then upper threshold 0 lower threshold 0
    # dont let any position exceed 10L
    current_diff = current_instant$quote.mid - current_instant$quote.f_mid
    new_position = new_position + position
    cond4 <- (new_position < 0)
    new_position[cond4] = 0
    # print("new function")
    if(calc_gross(new_position, current_instant)>MAX_GROSS){
        # print("Exposure limit reached")
        # print(calc_gross(new_position, current_instant))
        # pick most profitable position and close it
        # print(new_position)
        cond2 <- (new_position > 0 & position > 0 & new_position > position) | (new_position < 0 & position < 0 & new_position < position)
        new_position[cond2] = position[cond2]
        cond1 <- (new_position >= 0 & position <= 0) | (new_position <= 0 & position >= 0)
        new_position[cond1] = 0
        cond3 <- (new_position > 0 & position > 0 & new_position <= position) |
            (new_position < 0 & position < 0 & new_position >= position)
        all_conditions <- cond1 | cond2 | cond3
        no_conditions_indices <- which(!all_conditions)
        new_position[no_conditions_indices] = position[no_conditions_indices]
        # print(calc_gross(new_position, current_instant))
        # print("done")
        # print(new_position)
    }
    gross = calc_gross(new_position, current_instant)
   
    profit = rep(0, 16)
    # wipe out sell position
    # Vectorized operation for the first condition
    cond1 <- (new_position >= 0 & position <= 0) | (new_position <= 0 & position >= 0)
    profit[cond1] <- profit[cond1] + (current_diff[cond1] - avg_price[cond1]) * position[cond1]
    avg_price[cond1] <- current_diff[cond1]

    # Vectorized operation for the second condition
    cond2 <- (new_position > 0 & position > 0 & new_position > position) |
            (new_position < 0 & position < 0 & new_position < position)
    avg_price[cond2] <- (avg_price[cond2] * position[cond2] + current_diff[cond2] * (new_position[cond2] - position[cond2])) / new_position[cond2]

    # Vectorized operation for the third condition
    cond3 <- (new_position > 0 & position > 0 & new_position <= position) |
            (new_position < 0 & position < 0 & new_position >= position)
    profit[cond3] <- profit[cond3] + (current_diff[cond3] - avg_price[cond3]) * (position[cond3] - new_position[cond3])
    total_profit = total_profit + sum(profit)
    return (list(profit = total_profit, gross = gross, avg_price = avg_price, avg_fut_price = avg_fut_price, new_position = new_position))
}

len = length(month)
for (j in seq_along(month)) {
    # if(j!=len)
    #     next
    file_name <- month[j]
    file_path <- file.path(directory, file_name)
    mapping_file_path <- file.path(directory, mapping_month[j])
    if (file.exists(file_path)) {
        data <- fread(file_path)
        mapping_data = get_mapping_data(fread(mapping_file_path))
        grouped_data = get_grouped_data(data, mapping_data$underlying_mapping)
        # current_instant <- get_new_df(grouped_data[[1]], mapping_data$expiry_mapping)
        # print(current_instant)
        for (i in seq_along(grouped_data)) {
            current_instant <- get_new_df(grouped_data[[i]], mapping_data$expiry_mapping)
            # print(current_instant) 
            new_position = get_position(current_instant, upper_thresholds, lower_thresholds)
            result = get_profits(new_position, position, current_instant, avg_price, avg_fut_price, profit)
            profit = result$profit
            gross = result$gross
            avg_price = result$avg_price
            avg_fut_price = result$avg_fut_price
            position = result$new_position
            print(j)
            print(position)
            print(profit)
            print(gross)
            # if(i==1000){
                # break}
            if(i==length(grouped_data) && j==len){
                temp = 0
                for(k in 1:16){
                    if(position[k]!=0){
                        profit = profit + (0 - avg_price[k]) * position[k]
                        exposure = abs(position[k]) * (current_instant$quote.mid[k] + 0.1 * current_instant$quote.f_mid[k])
                        temp = temp + exposure
                    }
                }
                print(temp)}
            #     break
            # }
        }  
        print(profit)
        print(gross)
        # break
    }
}