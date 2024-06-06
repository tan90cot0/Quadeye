source("helper.r")
library(data.table)
options(scipen = 999)

MAX_GROSS = 385000000
# MAX_GROSS = 100000000

strategy <- function(position, current_instant, upper_thresholds, lower_thresholds){
    # if -ve position at 15 min then upper threshold 0 lower threshold 0
    # dont let any position exceed 10L
    new_position = position + get_position(current_instant, upper_thresholds, lower_thresholds)
    cond4 <- (new_position < 0)
    new_position[cond4] = 0
    if(calc_gross(new_position, current_instant)>MAX_GROSS){
        # print("Exposure limit reached")
        # pick most profitable position and close it
        cond2 <- (new_position > 0 & position > 0 & new_position > position) | (new_position < 0 & position < 0 & new_position < position)
        new_position[cond2] = position[cond2]
        cond1 <- (new_position >= 0 & position <= 0) | (new_position <= 0 & position >= 0)
        new_position[cond1] = 0
        cond3 <- (new_position > 0 & position > 0 & new_position <= position) |
            (new_position < 0 & position < 0 & new_position >= position)
        all_conditions <- cond1 | cond2 | cond3
        no_conditions_indices <- which(!all_conditions)
        new_position[no_conditions_indices] = position[no_conditions_indices]
    }
    
    return(new_position)
}

file_path <- "/home/aryand2024/scripts/month1.csv"
df <- read.csv(file_path)
df$datetime <- paste(df$date, df$time)
split_dfs <- split(df, df$datetime)
gross = 0
position <- rep(0, 16)
avg_price <- rep(0, 16)
profit = 0
res = init_thresholds()
upper_thresholds = res$upper_thresholds
lower_thresholds = res$lower_thresholds

prev_date <- "start------"
for (i in 1:length(split_dfs)) {
    current_instant = split_dfs[[i]]
    current_diff = current_instant$quote.mid - current_instant$quote.f_mid
    if(current_instant$date[1] != prev_date){
        prev_date = current_instant$date[1]
        print(paste("date =", prev_date))
        print(paste("position =", position))
        print(paste("profit =", profit))
        print(paste("gross =", gross))
        print("--------------------------------------------------")
    }
    new_position = strategy(position, current_instant, upper_thresholds, lower_thresholds)
    gross = calc_gross(new_position, current_instant)
    result = get_profits(new_position, position, current_diff, avg_price)
    profit = profit + result$profit
    avg_price = result$avg_price
    position = new_position
    if(i==length(split_dfs)){
        temp = 0
        for(k in 1:16){
            if(position[k]!=0){
                profit = profit - avg_price[k] * position[k]
                exposure = abs(position[k]) * (current_instant$quote.mid[k] + 0.1 * current_instant$quote.f_mid[k])
                temp = temp + exposure
            }
        }
        print(temp)
        print(profit)
    }
}