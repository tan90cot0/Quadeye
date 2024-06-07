source("helper.r")
library(data.table)
options(scipen = 999)

MAX_GROSS = 320000000
file_path <- "/home/aryand2024/scripts/month1.csv"
df <- read.csv(file_path)
df$datetime <- paste(df$date, df$time)
split_dfs <- split(df, df$datetime)
gross = 0
position <- rep(0, 16)
avg_price <- rep(0, 16)
profit = 0

rolling_mean = rep(0, 16)
quantity_mean = 0

rolling_mean_reset = rep(0, 16)
quantity_mean_reset = 0
window_size_mean_reset = 700

rolling_mean_window = rep(0, 16)
quantity_mean_window = 0
window_size_mean_window = 20

rolling_exp_avg = rep(0, 16)
window_size_exp_avg = 325

turnover = 0
maxgross = 0
maxgross_arr = c()

constant_thresholds <- function(current_instant){
    positions = rep(0, 16)
    res = get_thresholds()
    volumes = pmin(current_instant$quote.bidSz, pmin(current_instant$quote.askSz, pmin(current_instant$quote.f_bidSz, current_instant$quote.f_askSz)))
    buy_cond = current_instant$rate > res$upper_thresholds[current_instant$symbol]
    sell_cond = current_instant$rate < res$lower_thresholds[current_instant$symbol]
    positions[buy_cond] = volumes[buy_cond]
    positions[sell_cond] = -volumes[sell_cond]
    return(positions)
}

rolling_mean_fullday <- function(current_instant){
    positions = rep(0, 16)
    current_diff = current_instant$quote.f_mid - current_instant$quote.mid
    volumes = pmin(current_instant$quote.bidSz, pmin(current_instant$quote.askSz, pmin(current_instant$quote.f_bidSz, current_instant$quote.f_askSz)))
    buy_cond = current_diff > rolling_mean
    sell_cond = current_diff < rolling_mean
    positions[buy_cond] = volumes[buy_cond]
    positions[sell_cond] = -volumes[sell_cond]
    return(positions)
}

rolling_mean_resett <- function(current_instant){
    positions = rep(0, 16)
    current_diff = current_instant$quote.f_mid - current_instant$quote.mid
    volumes = pmin(current_instant$quote.bidSz, pmin(current_instant$quote.askSz, pmin(current_instant$quote.f_bidSz, current_instant$quote.f_askSz)))
    buy_cond = current_diff > rolling_mean_reset
    sell_cond = current_diff < rolling_mean_reset
    positions[buy_cond] = volumes[buy_cond]
    positions[sell_cond] = -volumes[sell_cond]
    return(positions)
}

rolling_mean_windoww <- function(current_instant){
    positions = rep(0, 16)
    current_diff = current_instant$quote.f_mid - current_instant$quote.mid
    volumes = pmin(current_instant$quote.bidSz, pmin(current_instant$quote.askSz, pmin(current_instant$quote.f_bidSz, current_instant$quote.f_askSz)))
    buy_cond = current_diff > rolling_mean_window
    sell_cond = current_diff < rolling_mean_window
    positions[buy_cond] = volumes[buy_cond]
    positions[sell_cond] = -volumes[sell_cond]
    return(positions)
}

exponential_moving_average <- function(current_instant){
    positions = rep(0, 16)
    current_diff = current_instant$quote.f_mid - current_instant$quote.mid
    volumes = pmin(current_instant$quote.bidSz, pmin(current_instant$quote.askSz, pmin(current_instant$quote.f_bidSz, current_instant$quote.f_askSz)))
    buy_cond = current_diff > rolling_exp_avg
    sell_cond = current_diff < rolling_exp_avg
    positions[buy_cond] = volumes[buy_cond]
    positions[sell_cond] = -volumes[sell_cond]
    return(positions)
}

strategy = exponential_moving_average
current_diffs = c()
prev_date <- "start"
for (i in 1:length(split_dfs)) {
    current_instant = split_dfs[[i]]
    current_diff = current_instant$quote.f_mid - current_instant$quote.mid
    current_diffs = c(current_diffs, current_diff)
    if(current_instant$date[1] != prev_date && prev_date != "start"){
        df <- data.frame(
            date = prev_date,
            symbol = current_instant$symbol,
            pnl = profit,
            gross = gross,
            turnover = turnover,
            position = position
            )
        print(df)
        cat("\n")
        print(paste("Date =", prev_date))
        print(paste("profit (in L) =", sum(profit)/100000))
        print(paste("gross (in Cr) =", sum(gross)/10000000))
        print(paste("MaxGross (in Cr) =", maxgross/10000000))
        print(paste("turnover (in Cr) =", sum(turnover)/10000000))
        cat("\n")
        print("--------------------------------------------------")
        rolling_mean = rep(0, 16)
        quantity_mean = 0
        rolling_mean_reset = rep(0, 16)
        quantity_mean_reset = 0
        maxgross_arr = c(maxgross_arr, maxgross)
        maxgross = 0
    }
    if(quantity_mean_reset == window_size_mean_reset){
        rolling_mean_reset = rep(0, 16)
        quantity_mean_reset = 0
    }

    new_position = position + strategy(current_instant)
    new_position = modify_position(new_position, position, current_instant)
    gross = calc_gross(new_position, current_instant)
    maxgross = max(maxgross, sum(gross))
    result = get_profits(new_position, position, current_instant, avg_price)
    profit = profit + result$profit
    avg_price = result$avg_price
    turnover = turnover + result$turnover
    position = new_position

    rolling_mean = (rolling_mean * quantity_mean + current_diff) / (quantity_mean + 1)
    quantity_mean = quantity_mean + 1

    rolling_mean_reset = (rolling_mean_reset * quantity_mean_reset + current_diff) / (quantity_mean_reset + 1)
    quantity_mean_reset = quantity_mean_reset + 1

    if(quantity_mean_window == window_size_mean_window){
        to_remove = current_diffs[i - window_size_mean_window]
        rolling_mean_window = (rolling_mean_window * quantity_mean_window + current_diff - to_remove) / quantity_mean_window
    }
    else{
        rolling_mean_window = (rolling_mean_window * quantity_mean_window + current_diff) / (quantity_mean_window + 1)
        quantity_mean_window = quantity_mean_window + 1
    }

    # Exponential Moving Average
    alpha = 2/(window_size_exp_avg + 1)
    rolling_exp_avg = alpha * current_diff + (1 - alpha) * rolling_exp_avg

    if(i==length(split_dfs)){
        temp = 0
        profit = profit + avg_price * position
        gross = abs(position) * (current_instant$quote.mid + 0.1 * current_instant$quote.f_mid)
        df <- data.frame(
            date = prev_date,
            symbol = current_instant$symbol,
            pnl = profit,
            gross = gross,
            turnover = turnover,
            position = position
            )
        print(df)
        cat("\n")
        print(paste("Date =", prev_date))
        print(paste("profit (in L) =", sum(profit)/100000))
        print(paste("gross (in Cr) =", sum(gross)/10000000))
        print(paste("MaxGross (in Cr) =", maxgross/10000000))
        print(paste("turnover (in Cr) =", sum(turnover)/10000000))
        cat("\n")
        print("--------------------------------------------------")
    }
    prev_date = current_instant$date[1]
}
print(paste("Mean of MaxGross (in Cr) =", mean(maxgross_arr)/10000000))
print(paste("Std Dev of MaxGross (in Cr) =", sd(maxgross_arr)/10000000))