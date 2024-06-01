import pandas as pd

df = pd.read_csv('/Users/aryan/Desktop/qteams/hffh/internTask2024/tuesday_dist/2/earningsSector.csv')

columns_to_change = list(df.columns)[2:]
columns_to_change.sort()
pct_change_subset = df[columns_to_change].pct_change()

# Combine original DataFrame with percentage change DataFrame
df_with_pct_change = pd.concat([df, pct_change_subset.add_suffix('_pct_change')], axis=1)

df_with_pct_change.drop(columns=columns_to_change, inplace=True)

grouped = df_with_pct_change.groupby('date')
dataframes = {date: group.copy() for date, group in grouped}

cnt = 0
columns = [col + '_pct_change' for col in columns_to_change]
earning_dates = [[] for i in range(16)]
for date, df in dataframes.items():
    max_change = list(df[columns].max(axis=0))
    for inst in range(16):
        if max_change[inst] > 0.01:
            earning_dates[inst].append(date)

earning_dates_df = pd.DataFrame(earning_dates).T
earning_dates_df.columns = columns_to_change

earning_dates_df.to_csv('earningdates.csv', index=False)