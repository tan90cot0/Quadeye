## Algorithm description

1. To get my encodings, rotate your phone 45 degrees clockwise.
2. In other words, the north-west part of the screen is my origin in the graph.
3. To find the most optimal path, I first find the possible (valid) moves in the current state (graph).
4. These valid moves can be thought of as neighbors of the current state.
5. Since I have a given node and its neighbors, I can do a BFS traversal to find the shortest path.
6. Whenever the goal state (all targets completed) is reached, I break out of the loop.
7. Whenever in a state, the number of moves left is less than the number of targets remaining, I break out since the target can never be reached.
8. I maintain a visited set to keep track of the (states, actions) I have visited.

## How to decode the input files

1. `.` -> no boundary wall
2. `X` -> Normal tile
3. `Y` -> Target block
4. `W` -> Wall
5. `P` -> Spider
6. `G` -> Grasshopper
7. `S` -> Snail
8. `L` -> Ladybug
9. `B` -> Butterfly
10. `H` -> Honeybee

## How to run the code

1. Just run the command `sh run.sh <moves> <file_path>`

## Output description

1. I first print the stepwise output: The action to take, then I show the state of the board before and after the action.
2. Then I print the final state of the board, along with a combined list of actions to be taken to reach the goal state.
3. If no solution is found, I print "No solution found".
