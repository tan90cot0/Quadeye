import pandas as pd
df = pd.read_csv('findposition.csv')

bid = list(df['bid'])
ask = list(df['ask'])
times = list(df['time'])
time = df.shape[0]
dp = [[0 for i in range(time)] for j in range(3)]
dp_parent = [[-1 for i in range(time)] for j in range(3)]

total_profit = 0

for t in range(time):
    if times[t] == 100000:
        total_profit+=dp[0][t-1]
        dp[0][t] = 0
        dp[1][t] = -(1+0.0005)*ask[t]
        dp[2][t] = (1-0.0005)*bid[t]
        dp_parent[0][t] = None
        dp_parent[1][t] = None
        dp_parent[2][t] = None
    else:
        temp = [    
                dp[0][t-1], 
                dp[1][t-1] + bid[t]*(1-0.0005), 
                dp[2][t-1] - ask[t]*(1+0.0005)
                ]
        ind = temp.index(max(temp))
        dp[0][t] = temp[ind]
        dp_parent[0][t] = ind

        temp = [
            dp[0][t-1] - ask[t]*(1+0.0005), 
            dp[1][t-1], 
            dp[2][t-1] - 2*ask[t]*(1+0.0005)
            ]
        ind = temp.index(max(temp))
        dp[1][t] = temp[ind]
        dp_parent[1][t] = ind

        temp = [
            dp[0][t-1] + bid[t]*(1-0.0005), 
            dp[1][t-1] + 2*bid[t]*(1-0.0005), 
            dp[2][t-1]
            ]
        ind = temp.index(max(temp))
        dp[2][t] = temp[ind]
        dp_parent[2][t] = ind

total_profit+=dp[0][time-1]

positions = [0 for i in range(time)]
for t in range(time-1, 0, -1):
    if times[t] == 100000:
        positions[t-1] = 0
    else:
        positions[t-1] = dp_parent[positions[t]][t]

positions = [-1 if pos==2 else pos for pos in positions]

df['position'] = positions
df.to_csv('findPosition_ans.csv', index=False)
f = open("netpnl.txt", "w")
f.write(str(total_profit))
f.close()

prev_pos = 0
profit = 0
for t, pos in enumerate(positions):
    if pos<prev_pos:
        profit+=(prev_pos-pos)*bid[t]*(1-0.0005)
    if pos>prev_pos:
        profit-=(pos-prev_pos)*ask[t]*(1+0.0005)
    prev_pos = pos
print(profit)