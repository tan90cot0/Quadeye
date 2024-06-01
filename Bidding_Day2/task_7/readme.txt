1. I separate the dataframes into daywise dataframes (all three)
2. I then make a dictionary out of the values of instBB.csv, with boxATime as key and boxBTime as values (for each day)
3. With the above dictionary, I find the corresponding B time for each A time in the boxA_instAA01.csv file
4. Now I see if the translated B time is ahead or behind the corresponding B localtime for that entry
5. Based on whether it leads or lags, I fill the leaderOrFollower column with 1/0/-1