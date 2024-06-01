1. I separated the dataframe into daywise dataframes
2. Using the formula for return.disc.offset, I found the values of the required columns
3. To find the midprice at a future value, I perform a binary search on the mid values list to optimise the speed
4. Also, instead of making multiple df accesses, I store whatever I need to refer often in a list and access it from there
5. I also converted the time from the given format to seconds to make it easier to work with