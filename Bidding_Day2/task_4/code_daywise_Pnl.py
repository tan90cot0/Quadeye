import pandas as pd
import sys

path1 = sys.argv[1]
build_thresh = float(sys.argv[2])
liq_thresh = float(sys.argv[3])
path2 = sys.argv[4]

# df = pd.read_csv('/Users/aryan/Desktop/qteams/hffh/internTask2024/tuesday_dist/2/pnlframe_compute.csv')

df = pd.read_csv(path1)

non_zero_alpha_df = df[df['alpha'] != 0]
# Calculate quantiles of absolute value of non-zero alphas
alpha_quantiles = non_zero_alpha_df['alpha'].abs().quantile([0.75, 0.1])
# Define build threshold and liquidate threshold
# build_thresh = 69.5123945
# liq_thresh = 4.165573900000002
# build_thresh = alpha_quantiles[0.75]
# liq_thresh = alpha_quantiles[0.1]

grouped = df.groupby('date')
dataframes = {date: group.copy() for date, group in grouped}

dates = []
profits = []
volumes = []
for date, df in dataframes.items():
    position = 0
    profit = 0
    lots = 0
    total_vol = 0
    total_rows = len(df)
    money = 1000000
    for ind, row in enumerate(df.itertuples()):
        alpha = row.alpha
        price = row.price
        if alpha > build_thresh and ind < total_rows - 1:
            if position == 0:
            # buy and build position
                position = 1
                volume = money//price
                profit-= price * volume
                profit-= price * volume * 0.0001 # transaction cost
                lots = volume
                total_vol+=lots*price
            elif position == -1:
                # liquidate built position and buy
                position = 1
                
                profit-= price * lots
                profit-= price * lots * 0.0001 # transaction cost
                total_vol+=lots*price

                volume = money//price
                profit-= price * volume
                profit-= price * volume * 0.0001 # transaction cost
                lots = volume
                total_vol+=lots*price
            
        elif -alpha > build_thresh and ind < total_rows - 1:
            if position == 0:
                # sell and build position
                position = -1
                volume = money//price
                lots = volume
                profit+= price * volume
                profit-= price * volume * 0.0001
                total_vol+=lots*price
            elif position == 1:
                # liquidate built position and sell
                position = -1
                volume = money//price
                profit+= price * lots
                profit-= price * lots * 0.0001
                total_vol+=lots*price
                money+= lots * price
                profit-= price * volume * 0.0001
                profit+= price * volume
                lots = volume
                total_vol+=lots*price
        elif ((ind == total_rows - 1) or (abs(alpha) < liq_thresh and liq_thresh>0)):
            if position == 1:
                # sell and liquidate built position
                position = 0
                profit+= price * lots
                profit-= price * lots * 0.0001
                total_vol+=lots*price
            if position == -1:
                # buy and liquidate built position
                position = 0
                profit-= price * lots
                profit-= price * lots * 0.0001
                total_vol+=lots*price
        elif ((ind == total_rows - 1) or (abs(alpha) > -liq_thresh and liq_thresh<0)):
            if position == -1:
                # buy and liquidate built position
                position = 0
                profit-= price * lots
                profit-= price * lots * 0.0001
                total_vol+=lots*price
            if position == 1:
                # sell and liquidate built position
                position = 0
                profit+= price * lots
                profit-= price * lots * 0.0001
                total_vol+=lots*price
    dates.append(date)
    profits.append(profit)
    volumes.append(total_vol)

df = pd.DataFrame({
    'date': dates,
    'pnl': profits,
    'volume': volumes
})

# df2 = get_pnl_frame(df, build_thresh, liq_thresh)
# df.to_csv('daywisePnl_ans.csv', index=False)
df.to_csv(path2, index=False)