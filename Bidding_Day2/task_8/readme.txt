1. Since the reports are being released before the markets open everyday, the max volatility of each instrument will be at the opening time of everyday (9:45am)
2. I find the percentage changes between consecutive rows, then I separate the dataframe into daywise dataframes
3. Just in case there is a significant change in the market at some other time, I am finding the max percentage change of instrument values in a day (not just the change at 9:45am)
4. Here, the percentage change denotes the percentage difference between 2 consecutive values of the instrument (on 2 consecutives timestamps)
5. If the max percentage change is greater than 1%, I will consider that as a significant change in the market and add the corresponding date to the earning dates list of the corresponding instrument