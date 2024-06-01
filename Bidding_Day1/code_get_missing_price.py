import pandas as pd

df = pd.read_csv('FindMissingValues.csv')
df['time'] = (df['time']//1000).astype(str)
df['date'] = df['date'].astype(str)

for index, row in df.iterrows():
    l = len(row['time'])
    df.at[index, 'time'] = (6-l)*'0' + row['time']

df['datetime'] = pd.to_datetime(df['date'] + df['time'], format='%Y%m%d%H%M%S')

# Set the 'datetime' column as the index
df.set_index('datetime', inplace=True)

# Function to interpolate missing values day-wise
def interpolate_daywise(df):
    df_list = []
    for date, group in df.groupby(df.index.date):
        group['A'] = group['A'].interpolate(method='time')
        df_list.append(group)
    return pd.concat(df_list)

# Display the first few rows to understand the structure
# print("Original DataFrame with NaNs in A:")
# print(df)

# Step 1: Interpolation day-wise
df = interpolate_daywise(df)

# Step 2: Use B to refine the filled values in A
# Calculate the correlation between A (interpolated) and B
correlation = df['A'].corr(df['B'])
# print(f"\nCorrelation between A and B: {correlation}")

# Using the correlation to adjust interpolated values
# This is a simple approach, more complex models can be used as necessary
df['A_final'] = df['A'].copy()

# Find indices where A was originally NaN
nan_locs = df['A'].isna()

# Adjust the interpolated values based on B data
df.loc[nan_locs, 'A_final'] = df.loc[nan_locs, 'B'] * correlation

# Display the DataFrame after filling missing values
# print("\nDataFrame after filling missing values in A:")
# print(df)

# Check if there are any NaNs left in the final data
# print("\nNumber of NaNs left in A_final:", df['A_final'].isna().sum())

df_original = pd.read_csv('FindMissingValues.csv')
df['A'] = df['A_final']
df.drop(columns=['A_final'], inplace=True)

for index, row in df.iterrows():
    df.at[index, 'time'] = int(row['time'])*1000
    df.at[index, 'date'] = int(row['date'])

df.to_csv('filled_prices.csv', index=False)