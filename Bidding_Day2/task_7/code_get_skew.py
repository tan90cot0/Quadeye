import pandas as pd

df_A = pd.read_csv('/Users/aryan/Desktop/qteams/hffh/internTask2024/tuesday_dist/2/boxA_instAA01.csv')
df_B = pd.read_csv('/Users/aryan/Desktop/qteams/hffh/internTask2024/tuesday_dist/2/boxB_instAA10.csv')
df_inst = pd.read_csv('/Users/aryan/Desktop/qteams/hffh/internTask2024/tuesday_dist/2/instBB.csv')

grouped = df_A.groupby('date')
dataframes_A = {date: group.copy() for date, group in grouped}
grouped = df_B.groupby('date')
dataframes_B = {date: group.copy() for date, group in grouped}
grouped = df_inst.groupby('date')
dataframes_inst = {date: group.copy() for date, group in grouped}
dates = set(dataframes_A.keys())

for date in dates:
    df_A = dataframes_A[date]
    df_B = dataframes_B[date]
    df_inst = dataframes_inst[date]
    result_dict = df_inst.set_index('boxATime')['boxBTime'].to_dict()
    df_A['B_time'] = df_A['localTime'].map(result_dict)
    df_A['diff'] = df_A['B_time'] - df_B['localTime']
    df_A['leaderOrFollower'] = df_A['diff'].apply(lambda x: 1 if x > 0 else -1 if x < 0 else 0)
    df_A.drop(['B_time', 'diff'], axis=1, inplace=True)

combined_df = pd.concat(dataframes_A.values())

combined_df.to_csv('ans_skew.csv', index=False)