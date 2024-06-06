source("functions.R")
library(data.table)
options(scipen = 999)

result <- get_data(2)
month = result$month
mapping_month = result$mapping_month
directory = result$directory

gross = 400000000
position <- rep(0, 16)
avg_price <- rep(0, 16)
avg_fut_price <- rep(0, 16)
lower_threshold = 5
upper_threshold = 9
profit = 0

new_df <- data.frame(
        time_sec = numeric(),
        date = character(),
        symbol = character(),
        quote.mid = numeric(),
        quote.bid = numeric(),
        quote.ask = numeric(),
        quote.bidSz = numeric(),
        quote.askSz = numeric(),
        quote.f_mid = numeric(),
        quote.f_bid = numeric(),
        quote.f_ask = numeric(),
        quote.f_bidSz = numeric(),
        quote.f_askSz = numeric(),
        rate = numeric(),
        stringsAsFactors = FALSE
    )

len = length(month)
for (j in seq_along(month)) {
    file_name <- month[j]
    file_path <- file.path(directory, file_name)
    mapping_file_path <- file.path(directory, mapping_month[j])
    print(j)
    if (file.exists(file_path)) {
        data <- fread(file_path)
        mapping_data = get_mapping_data(fread(mapping_file_path))
        grouped_data = get_grouped_data(data, mapping_data$underlying_mapping)
        temp_df <- data.frame(
            time_sec = numeric(),
            date = character(),
            symbol = character(),
            quote.mid = numeric(),
            quote.bid = numeric(),
            quote.ask = numeric(),
            quote.bidSz = numeric(),
            quote.askSz = numeric(),
            quote.f_mid = numeric(),
            quote.f_bid = numeric(),
            quote.f_ask = numeric(),
            quote.f_bidSz = numeric(),
            quote.f_askSz = numeric(),
            rate = numeric(),
            stringsAsFactors = FALSE
        )
        for (i in seq_along(grouped_data)) {
            time_instant_data <- get_new_df(grouped_data[[i]], mapping_data$expiry_mapping)
            temp_df <- rbind(temp_df, time_instant_data)
        }  
        new_df <- rbind(new_df, temp_df)
    }
}
print(nrow(new_df))
write.csv(new_df, file = "month2.csv")