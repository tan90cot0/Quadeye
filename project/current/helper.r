init_thresholds <- function(){
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

    # lower_thresholds["B3SA3_BOVESPA"] = 5
    # lower_thresholds["BBAS3_BOVESPA"] = 5
    # lower_thresholds["BBDC4_BOVESPA"] = 5
    # lower_thresholds["CSNA3_BOVESPA"] = 5
    # lower_thresholds["GGBR4_BOVESPA"] = 5
    # lower_thresholds["HYPE3_BOVESPA"] = 5
    # lower_thresholds["ITSA4_BOVESPA"] = 5
    # lower_thresholds["ITUB4_BOVESPA"] = 5
    # lower_thresholds["JBSS3_BOVESPA"] = 5
    # lower_thresholds["MGLU3_BOVESPA"] = -100
    # lower_thresholds["NTCO3_BOVESPA"] = 5
    # lower_thresholds["PETR4_BOVESPA"] = 5
    # lower_thresholds["RENT3_BOVESPA"] = 5
    # lower_thresholds["USIM5_BOVESPA"] = 5
    # lower_thresholds["VALE3_BOVESPA"] = 5
    # lower_thresholds["WEGE3_BOVESPA"] = 5

    # upper_thresholds["B3SA3_BOVESPA"] = 10
    # upper_thresholds["BBAS3_BOVESPA"] = 10
    # upper_thresholds["BBDC4_BOVESPA"] = 10
    # upper_thresholds["CSNA3_BOVESPA"] = 10
    # upper_thresholds["GGBR4_BOVESPA"] = 10
    # upper_thresholds["HYPE3_BOVESPA"] = 10
    # upper_thresholds["ITSA4_BOVESPA"] = 10
    # upper_thresholds["ITUB4_BOVESPA"] = 10
    # upper_thresholds["JBSS3_BOVESPA"] = 10
    # upper_thresholds["MGLU3_BOVESPA"] = 100
    # upper_thresholds["NTCO3_BOVESPA"] = 10
    # upper_thresholds["PETR4_BOVESPA"] = 10
    # upper_thresholds["RENT3_BOVESPA"] = 10
    # upper_thresholds["USIM5_BOVESPA"] = 10
    # upper_thresholds["VALE3_BOVESPA"] = 10
    # upper_thresholds["WEGE3_BOVESPA"] = 10

    return(list(upper_thresholds = upper_thresholds, lower_thresholds = lower_thresholds))
}

calc_gross <- function(position, current_instant){
    gross = 0
    for(k in 1:16)
        gross = gross + abs(position[k]) * (current_instant$quote.mid[k] + 0.1 * current_instant$quote.f_mid[k])
    return(gross)
}

get_position <- function(current_instant, upper_thresholds, lower_thresholds){
    positions = rep(0, 16)
    for (i in 1:nrow(current_instant)) {
        row <- current_instant[i, ]
        if (row$rate > upper_thresholds[row$symbol])
            positions[i] = min(row$quote.bidSz, min(row$quote.askSz, min(row$quote.f_bidSz, row$quote.f_askSz)))
        if (row$rate < lower_thresholds[row$symbol])
            positions[i] = -min(row$quote.bidSz, min(row$quote.askSz, min(row$quote.f_bidSz, row$quote.f_askSz)))
    }
    return(positions)
}

get_profits <- function(new_position, position, current_diff, avg_price){
    profit = rep(0, 16)

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
    return (list(profit = sum(profit), avg_price = avg_price))
}