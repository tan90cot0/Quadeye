1. Used 3 dp arrays indexed on timestamps
2. Can transition from the 0, 1, -1 dp array to any of the other dp arrays from a timestamp to the next 
3. I separated the data based on days and then used the dp arrays to find the maximum profit within a day, because the final position in a day has to be 0
4. During the forward pass, I also store the 'parent pointers' in three more dp arrays. This is because at each step we are taking the max of 3 quantities and the end we want to figure out which choice it made.
5. Finally, at the end, we backtrack using the parent pointers to find the optimal positions at each timestamp.