import pandas as pd
import bisect

def find(times, time):
    return bisect.bisect_right(times, time) - 1

df = pd.read_csv('/Users/aryan/Desktop/qteams/hffh/internTask2024/tuesday_dist/2/computeRet.csv')
halflives = [100,600,7200,86400]

def task6(df, halflives):
    grouped = df.groupby('date')
    dataframes = {date: group.copy() for date, group in grouped}

    for df in dataframes.values():
        mid = list((df['bid'] + df['ask']) / 2)
        times = list(df['time'])
        for i in range(len(times)):
            times[i] = times[i] // 100000
            minutes = times[i] % 100
            hours = times[i] // 100
            times[i] = (hours*60 + minutes)*60

        return_disc = [[] for _ in range(len(halflives))]
        for i in range(len(return_disc)):
            for j in range(len(times)):
                idx = find(times, times[j] + halflives[i])
                return_disc[i].append((mid[idx] - mid[j])/mid[j])

        df['mid'] = mid
        for i in range(len(return_disc)):
            df[f'return.disc.{halflives[i]}'] = return_disc[i]

    combined_df = pd.concat(dataframes.values())

    combined_df.to_csv('computedReturns.csv', index=False)

task6(df, halflives)