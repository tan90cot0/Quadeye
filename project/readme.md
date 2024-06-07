# Day 1, monday 3 june
1. process data into the input format for the program

# Day 2, tuesday, 4 june
1. wrote a function to find basic PnL

# Day 3, wednesday, 5 june
1. tried to maximise pnl with different buy and sell strategies, but didnt handle exposure limit exceeded
2. converted one expiry cycle data to one csv file for faster processing

# Day 4, thursday, 6 june
1. liquidate when exposure limit exceeded
2. 15L with median wale thresholds
3. ran preprocessed csv, sorted rows in current time instant
4. gross = 38.5Cr profit = 17.5L, gross = 32Cr, profit = 14.5L

# Day 5, friday, 7 june
1. Results - 
    1. constant thresholds:
        1. (5, 10): 1315597
        2. (8.7, 9.2): 1355707
        3. (8.7, 9.5): 1389988
        4. (8.9, 9.5): 1405840
        5. (9.1, 9.5): 1462053
        6. (9.2, 9.5): 1477888
        7. (9.3, 9.5): 1486449
        8. (9.4, 9.5): 1498614
        9. (9.5, 9.5): 1509616
        10. (9.6, 9.6): 1516346
        11. (9.7, 9.7): 1536537
        12. (9.8, 9.8): 1546732
        13. (9.9, 9.9): 1551978 (best)
        14. (10, 10): 1521256
        15. (9.9, 10): 1529559
    2. Rolling mean: 
        1. +- 0: 1863429 (best)
        2. +- 0.001: 1844719
        3. +- 0.005: 714134.5
    3. Rolling mean with reset:
        1. 800: 1877775
        2. 750: 1889122
        3. 700: 1912718 (best)
        4. 600: 1865851
        5. 500: 1869665
    4. Rolling mean with window:
        1. 20: 1096842.5
        2. 200: 1099021 (best)
    5. Exponential moving average
        1. 700: 1818175
        2. 600: 1847525
        3. 500: 1855425.5
        4. 400: 1873806.5
        5. 375: 1874313
        6. 350: 1877899 (best)
        7. 325: 1874030
        8. 300: 1856391


# to do:
1. insights
2. pnl
3. mean+- std dev will work well when doing bid-ask. when working on mid price, making upper and lower threshold spread = 0 is best for maximising profit, because that will maximise money usage without incurring any transaction cost.