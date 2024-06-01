#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <fstream>
#include <map>
#include <set>
#include <stack>
#include <queue>
#include <list>

using namespace std;

// Struct for coordinates
struct Coordinate {
    int row;
    int col;
};

// Struct for action
struct Action {
    char animalType;
    Coordinate coordinate;
    char move;
    bool operator<(const Action& other) const {
        return animalType < other.animalType;
    }
};

vector<char> moves;

void print_action(Action action){
    switch(action.animalType){
        case 'L':
            cout << "LADYBUG" << " ";
            break;
        case 'B':
            cout << "BUTTERFLY" << " ";
            break;
        case 'S':
            cout << "SNAIL" << " ";
            break;
        case 'P':
            cout << "SPIDER" << " ";
            break;
        case 'G':
            cout << "GRASSHOPPER" << " ";
            break;
        case 'H':
            cout << "HONEYBEE" << " ";
            break;
    }

    cout << "AT (" <<action.coordinate.row << ", " << action.coordinate.col << ") --> ";

    switch(action.move){
        case 'L':
            cout << "LEFT" <<endl;
            break;
        case 'R':
            cout << "RIGHT" <<endl;
            break;
        case 'U':
            cout << "UP" <<endl;
            break;
        case 'D':
            cout << "DOWN" <<endl;
            break;
    }
}

void print_grid(vector<string> &grid){
    cout<< ". ";
    for(int j=0;j<grid[0].size()-1;j++){
        cout << j%10 << " ";
    }
    cout << endl;
    for (int i = 0; i < grid.size(); i++) {
        cout << i%10 << " ";
        for(int j=0;j<grid[i].size()-1;j++){
            cout << grid[i][j] << " ";
        }
        cout << endl;
    }
    cout<<endl;
}

bool check_valid_move_snail(Coordinate coordinate, char move, vector<string> &grid){
    int row = coordinate.row;
    int col = coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    switch (move) {
        case 'L':
            if (col == 1)
                return false;
            else if (grid[row][col - 1] == 'W')
                return false;
            else if (grid[row][col - 2] == 'X' || grid[row][col - 2] == 'Y')
                return true;
            else
                return false;
            break;
        case 'R':
            if (col == m - 2)
                return false;
            else if (grid[row][col + 1] == 'W')
                return false;
            else if (grid[row][col + 2] == 'X' || grid[row][col + 2] == 'Y')
                return true;
            else
                return false;
            break;
        case 'U':
            if (row == 1)
                return false;
            else if (grid[row - 1][col] == 'W')
                return false;
            else if (grid[row - 2][col] == 'X' || grid[row - 2][col] == 'Y')
                return true;
            else
                return false;
            break;
        case 'D':
            if (row == n - 2)
                return false;
            else if (grid[row + 1][col] == 'W')
                return false;
            else if (grid[row + 2][col] == 'X' || grid[row + 2][col] == 'Y')
                return true;
            else
                return false;
            break;
    }
    return true;
}

bool check_valid_move_spider(Coordinate coordinate, char move, vector<string> &grid){
    int row = coordinate.row;
    int col = coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    switch (move) {
        case 'L':
            if (col == 1)
                return false;
            else if (grid[row][col - 1] == 'W')
                return false;
            else {
                bool cond1 = grid[row][col - 2] == 'X' || grid[row][col - 2] == 'Y';
                bool cond2 = false;
                for(int i = col - 3; i >= 0; i--){
                    if(grid[row][i] == 'W' || grid[row][i] == 'S' || grid[row][i] == 'P' || grid[row][i] == 'G' || grid[row][i] == 'H' || grid[row][i] == 'B' || grid[row][i] == 'L'){
                        cond2 = true;
                        break;
                    }
                }
                if (cond1 && cond2)
                    return true;
                else
                    return false;
            }
            break;
        case 'R':
            if (col == m - 2)
                return false;
            else if (grid[row][col + 1] == 'W')
                return false;
            else {
                bool cond1 = grid[row][col + 2] == 'X' || grid[row][col + 2] == 'Y';
                bool cond2 = false;
                for(int i = col + 3; i <= m-1; i++){
                    if(grid[row][i] == 'W' || grid[row][i] == 'S' || grid[row][i] == 'P' || grid[row][i] == 'G' || grid[row][i] == 'H' || grid[row][i] == 'B' || grid[row][i] == 'L'){
                        cond2 = true;
                        break;
                    }
                }
                if (cond1 && cond2)
                    return true;
                else
                    return false;
            }
            break;
        case 'U':
            if (row == 1)
                return false;
            else if (grid[row - 1][col] == 'W')
                return false;
            else {
                bool cond1 = grid[row - 2][col] == 'X' || grid[row - 2][col] == 'Y';
                bool cond2 = false;
                for(int i = row - 3; i >= 0; i--){
                    if(grid[i][col] == 'W' || grid[i][col] == 'S' || grid[i][col] == 'P' || grid[i][col] == 'G' || grid[i][col] == 'H' || grid[i][col] == 'B' || grid[i][col] == 'L'){
                        cond2 = true;
                        break;
                    }
                }
                if (cond1 && cond2)
                    return true;
                else
                    return false;
            }
            break;
        case 'D':
            if (row == n - 2)
                return false;
            else if (grid[row + 1][col] == 'W')
                return false;
            else {
                bool cond1 = grid[row + 2][col] == 'X' || grid[row + 2][col] == 'Y';
                bool cond2 = false;
                for(int i = row + 3; i <= n-1; i++){
                    if(grid[i][col] == 'W' || grid[i][col] == 'S' || grid[i][col] == 'P' || grid[i][col] == 'G' || grid[i][col] == 'H' || grid[i][col] == 'B' || grid[i][col] == 'L'){
                        cond2 = true;
                        break;
                    }
                }
                if (cond1 && cond2)
                    return true;
                else
                    return false;
            }
            break;
    }
    return true;
}

bool check_valid_move_grasshopper(Coordinate coordinate, char move, vector<string> &grid){
    int row = coordinate.row;
    int col = coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    switch (move) {
        case 'L':
            if (col == 1)
                return false;
            else {
                bool cond = false;
                for(int i = col - 2; i >= 0; i-=2){
                    if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                        cond = true;
                        break;
                    }
                    if(grid[row][i] == '.')
                        return false;
                }
                return cond;
            }
            break;
        case 'R':
            if (col == m - 2)
                return false;
            else {
                bool cond = false;
                for(int i = col + 2; i <= m-2; i+=2){
                    if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                        cond = true;
                        break;
                    }
                    if(grid[row][i] == '.')
                        return false;
                }
                return cond;
            }
            break;
        case 'U':
            if (row == 1)
                return false;
            else {
                bool cond = false;
                for(int i = row - 2; i >= 0; i-=2){
                    if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                        cond = true;
                        break;
                    }
                    if(grid[i][col] == '.')
                        return false;
                }
                return cond;
            }
            break;
        case 'D':
            if (row == n - 2)
                return false;
            else {
                bool cond = false;
                for(int i = row + 2; i <= n-2; i+=2){
                    if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                        cond = true;
                        break;
                    }
                    if(grid[i][col] == '.')
                        return false;
                }
                return cond;
            }
            break;
    }
    return true;
}

bool check_valid_move_honeybee(Coordinate coordinate, char move, vector<string> &grid){
    int row = coordinate.row;
    int col = coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    switch (move) {
        case 'L':
            if (col == 1)
                return false;
            else {
                for(int i = col - 4; i >= 0; i-=2){
                    if (grid[row][i] == 'X' || grid[row][i] == 'Y')
                        return true;
                    if (grid[row][i] == '.')
                        return false;
                }
                return false;
            }
            break;
        case 'R':
            if (col == m - 2)
                return false;
            else {
                
                for(int i = col + 4; i <= m-1; i+=2){
                    if (grid[row][i] == 'X' || grid[row][i] == 'Y')
                        return true;
                    if (grid[row][i] == '.')
                        return false;
                }
                return false;
            }
            break;
        case 'U':
            if (row == 1)
                return false;
            else {
                for(int i = row - 4; i >= 0; i-=2){
                    if (grid[i][col] == 'X' || grid[i][col] == 'Y')
                        return true;
                    if (grid[i][col] == '.')
                        return false;
                }
                return false;
            }
            break;
        case 'D':
            if (row == n - 2)
                return false;
            else {
                for(int i = row + 4; i <= n-1; i+=2){
                    if (grid[i][col] == 'X' || grid[i][col] == 'Y')
                        return true;
                    if (grid[i][col] == '.')
                        return false;
                }
                return false;
            }
            break;
    }
    return false;
}

bool check_valid_move_ladybug(Coordinate coordinate, char move, vector<string> &grid){
    int row = coordinate.row;
    int col = coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    switch (move) {
        case 'L':
            if (col == 1)
                return false;
            else if (grid[row][col - 1] == 'W')
                return false;
            else {
                if (grid[row][col - 2] == 'X' || grid[row][col - 2] == 'Y'){
                    if(col>=4 && (grid[row][col-4] != '.'))
                        return true;
                    if(grid[row][col-3] == 'W')
                        return true;
                    return false;
                }  
                else
                    return false;
            }
            break;
        case 'R':
            if (col == m - 2)
                return false;
            else if (grid[row][col + 1] == 'W')
                return false;
            else {
                if (grid[row][col+2] == 'X' || grid[row][col+2] == 'Y'){
                    if(col<=m-5 && (grid[row][col+4] != '.'))
                        return true;
                    if(grid[row][col+3] == 'W')
                        return true;
                    return false;
                }  
                else
                    return false;
            }
            break;
        case 'U':
            if (row == 1)
                return false;
            else if (grid[row - 1][col] == 'W')
                return false;
            else {
                if (grid[row-2][col] == 'X' || grid[row-2][col] == 'Y'){
                    if(row>=4 && (grid[row-4][col] != '.'))
                        return true;
                    if(grid[row-3][col] == 'W')
                        return true;
                    return false;
                }  
                else
                    return false;
            }
            break;
        case 'D':
            if (row == n - 2)
                return false;
            else if (grid[row + 1][col] == 'W')
                return false;
            else {
                if (grid[row+2][col] == 'X' || grid[row+2][col] == 'Y'){
                    if(row<=n-5 && (grid[row+4][col] != '.'))
                        return true;
                    if(grid[row+3][col] == 'W')
                        return true;
                    return false;
                }  
                else
                    return false;
            }
            break;
    }
    return true;
}

bool check_valid_move_butterfly(Coordinate coordinate, char move, vector<string> &grid){
    int row = coordinate.row;
    int col = coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    switch (move) {
        case 'L':
            if (col == 1)
                return false;
            else {
                for(int i = col - 6; i >= 0; i-=2){
                    if (grid[row][i] == 'X' || grid[row][i] == 'Y')
                        return true;
                    if (grid[row][i] == '.')
                        return false;
                }
                return false;
            }
            break;
        case 'R':
            if (col == m - 2)
                return false;
            else {
                
                for(int i = col + 6; i <= m-1; i+=2){
                    if (grid[row][i] == 'X' || grid[row][i] == 'Y')
                        return true;
                    if (grid[row][i] == '.')
                        return false;
                }
                return false;
            }
            break;
        case 'U':
            if (row == 1)
                return false;
            else {
                for(int i = row - 6; i >= 0; i-=2){
                    if (grid[i][col] == 'X' || grid[i][col] == 'Y')
                        return true;
                    if (grid[i][col] == '.')
                        return false;
                }
                return false;
            }
            break;
        case 'D':
            if (row == n - 2)
                return false;
            else {
                for(int i = row + 6; i <= n-1; i+=2){
                    if (grid[i][col] == 'X' || grid[i][col] == 'Y')
                        return true;
                    if (grid[i][col] == '.')
                        return false;
                }
                return false;
            }
            break;
    }
    return false;
}

bool check_valid_move(char animalType, Coordinate coordinate, char move, vector<string> &grid) {
    switch(animalType){
        case 'L':
            return check_valid_move_ladybug(coordinate, move, grid);
            break;
        case 'B':
            return check_valid_move_butterfly(coordinate, move, grid);
            break;
        case 'S':
            return check_valid_move_snail(coordinate, move, grid);
            break;
        case 'P':
            return check_valid_move_spider(coordinate, move, grid);
            break;
        case 'G':
            return check_valid_move_grasshopper(coordinate, move, grid);
            break;
        case 'H':
            return check_valid_move_honeybee(coordinate, move, grid);
            break;
        default:
            return false;
    }
}

vector<Action> generateActions(vector<string> &grid){
    vector<Action> actions;
    for (int i = 1; i < grid.size(); i+=2) {
        for (int j = 1; j < grid[i].size() - 1; j+=2) {
            Coordinate coordinate;
            coordinate.row = i;
            coordinate.col = j;
            if (grid[i][j] != '.' && grid[i][j] != 'W' && grid[i][j] != 'Y' && grid[i][j] != 'X') {
                for (int k = 0; k < 4; k++) {
                    if (check_valid_move(grid[i][j], coordinate, moves[k], grid)) {
                        Action action;
                        action.animalType = grid[i][j];
                        action.coordinate = coordinate;
                        action.move = moves[k];
                        // cout<<action.move<<endl;
                        // print_action(action);
                        actions.push_back(action);
                    }
                }

            }
        }
    }
    return actions;
}

void perform_action_snail(vector<string> &grid, Action action){
    int row = action.coordinate.row;
    int col = action.coordinate.col;
    grid[row][col] = 'X';
    switch(action.move){
        case 'L':
            if(grid[row][col-2] == 'Y')
                grid[row][col-2] = 'X';
            else
                grid[row][col-2] = 'S';
            break;
        case 'R':
            if(grid[row][col+2] == 'Y')
                grid[row][col+2] = 'X';
            else
                grid[row][col+2] = 'S';
            break;
        case 'U':
            if(grid[row-2][col] == 'Y')
                grid[row-2][col] = 'X';
            else
                grid[row-2][col] = 'S';
            break;
        case 'D':
            if(grid[row+2][col] == 'Y')
                grid[row+2][col] = 'X';
            else
                grid[row+2][col] = 'S';
            break;
    }
}

void perform_action_spider(vector<string> &grid, Action action){
    int row = action.coordinate.row;
    int col = action.coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    grid[row][col] = 'X';
    int new_col;
    int new_row;
    switch(action.move){
        case 'L':
            new_col = col-2;
            for(;new_col>=0;new_col--){
                if(grid[row][new_col-1] == 'W')
                    break;
                if(new_col>=2 && (grid[row][new_col-2] == 'S' || grid[row][new_col-2] == 'P' || grid[row][new_col-2] == 'G' || grid[row][new_col-2] == 'H' || grid[row][new_col-2] == 'B' || grid[row][new_col-2] == 'L'))
                    break;
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'P';
            break;
        case 'R':
            new_col = col+2;
            for(;new_col<=m-1;new_col++){
                if(grid[row][new_col+1] == 'W')
                    break;
                if(new_col<=m-3 && (grid[row][new_col+2] == 'S' || grid[row][new_col+2] == 'P' || grid[row][new_col+2] == 'G' || grid[row][new_col+2] == 'H' || grid[row][new_col+2] == 'B' || grid[row][new_col+2] == 'L'))
                    break;
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'P';
            break;
        case 'U':
            new_row = row-2;
            for(;new_row>=0;new_row--){
                if(grid[new_row-1][col] == 'W')
                    break;
                if(new_row>=2 && (grid[new_row-2][col] == 'S' || grid[new_row-2][col] == 'P' || grid[new_row-2][col] == 'G' || grid[new_row-2][col] == 'H' || grid[new_row-2][col] == 'B' || grid[new_row-2][col] == 'L'))
                    break;
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'P';
            break;
        case 'D':
            new_row = row+2;
            for(;new_row<=n-1;new_row++){
                if(grid[new_row+1][col] == 'W')
                    break;
                if(new_row<=n-3 && (grid[new_row+2][col] == 'S' || grid[new_row+2][col] == 'P' || grid[new_row+2][col] == 'G' || grid[new_row+2][col] == 'H' || grid[new_row+2][col] == 'B' || grid[new_row+2][col] == 'L'))
                    break;
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'P';
            break;
    }
}

void perform_action_grasshopper(vector<string> &grid, Action action){
    int row = action.coordinate.row;
    int col = action.coordinate.col;
    grid[row][col] = 'X';
    int n = grid.size();
    int m = grid[0].size() - 1;
    int new_col;
    int new_row;
    switch(action.move){
        case 'L':
            for(int i = col - 2; i >= 0; i-=2){
                if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                    new_col = i;
                    break;
                }
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'G';
            break;
        case 'R':
            for(int i = col + 2; i <= m-2; i+=2){
                if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                    new_col = i;
                    break;
                }
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'G';
            break;
        case 'U':
            for(int i = row - 2; i >= 0; i-=2){
                if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                    new_row = i;
                    break;
                }
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'G';
            break;
        case 'D':
            for(int i = row + 2; i <= n-2; i+=2){
                if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                    new_row = i;
                    break;
                }
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'G';
            break;
    }
    // return;
}

void perform_action_honeybee(vector<string> &grid, Action action){
    int row = action.coordinate.row;
    int col = action.coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    int new_col;
    int new_row;
    grid[row][col] = 'X';
    switch(action.move){
        case 'L':
            for(int i = col - 4; i >= 0; i-=2){
                if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                    new_col = i;
                    break;
                }
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'H';
            break;
        case 'R':
            for(int i = col + 4; i <= m-2; i+=2){
                if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                    new_col = i;
                    break;
                }
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'H';
            break;
        case 'U':
            for(int i = row - 4; i >= 0; i-=2){
                if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                    new_row = i;
                    break;
                }
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'H';
            break;
        case 'D':
            for(int i = row + 4; i <= n-2; i+=2){
                if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                    new_row = i;
                    break;
                }
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'H';
            break;
    }
}

void perform_action_ladybug(vector<string> &grid, Action action){
    int row = action.coordinate.row;
    int col = action.coordinate.col;
    grid[row][col] = 'X';
    int new_col;
    int new_row;
    switch(action.move){
        case 'L':
            new_col = col-2;
            if(grid[row][new_col-1]!='W' && (grid[row][new_col-2]=='X' || grid[row][new_col-2]=='Y'))
                new_col-=2;
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'L';
            break;
        case 'R':
            new_col = col+2;
            if(grid[row][new_col+1]!='W' && (grid[row][new_col+2]=='X' || grid[row][new_col+2]=='Y'))
                new_col+=2;
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'L';
            break;
        case 'U':
            new_row = row-2;
            if(grid[new_row-1][col]!='W' && (grid[new_row-2][col]=='X' || grid[new_row-2][col]=='Y'))
                new_row-=2;
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'L';
            break;
        case 'D':
            new_row = row+2;
            if(grid[new_row+1][col]!='W' && (grid[new_row+2][col]=='X' || grid[new_row+2][col]=='Y'))
                new_row+=2;
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'L';
            break;
    }
}

void perform_action_butterfly(vector<string> &grid, Action action){
    int row = action.coordinate.row;
    int col = action.coordinate.col;
    int n = grid.size();
    int m = grid[0].size() - 1;
    int new_col;
    int new_row;
    grid[row][col] = 'X';
    switch(action.move){
        case 'L':
            for(int i = col - 6; i >= 0; i-=2){
                if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                    new_col = i;
                    break;
                }
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'B';
            break;
        case 'R':
            for(int i = col + 6; i <= m-2; i+=2){
                if(grid[row][i] == 'X' || grid[row][i] == 'Y'){
                    new_col = i;
                    break;
                }
            }
            if(grid[row][new_col] == 'Y')
                grid[row][new_col] = 'X';
            else
                grid[row][new_col] = 'B';
            break;
        case 'U':
            for(int i = row - 6; i >= 0; i-=2){
                if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                    new_row = i;
                    break;
                }
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'B';
            break;
        case 'D':
            for(int i = row + 6; i <= n-2; i+=2){
                if(grid[i][col] == 'X' || grid[i][col] == 'Y'){
                    new_row = i;
                    break;
                }
            }
            if(grid[new_row][col] == 'Y')
                grid[new_row][col] = 'X';
            else
                grid[new_row][col] = 'B';
            break;
    }
}

void perform_action(vector<string> &grid, Action action){
    switch(action.animalType){
        case 'L':
            perform_action_ladybug(grid, action);
            break;
        case 'B':
            perform_action_butterfly(grid, action);
            break;
        case 'S':
            perform_action_snail(grid, action);
            break;
        case 'P':
            perform_action_spider(grid, action);
            break;
        case 'G':
            perform_action_grasshopper(grid, action);
            break;
        case 'H':
            perform_action_honeybee(grid, action);
            break;
    }
}

int goal_test(vector<string> &grid){
    int cnt = 0;
    for(int i=1;i<grid.size();i+=2){
        for(int j=1;j<grid[i].size();j+=2){
            if(grid[i][j] == 'Y')
                cnt++;
        }
    }
    return cnt;
}

vector<Action> bfs(vector<string> &grid, int moves){
    vector<Action> actions;
    queue<pair<pair<vector<string>,vector<Action> >, int> > q;
    q.push(make_pair(make_pair(grid, actions), moves));
    set<pair<vector<string>, Action > > visited;
    while(!q.empty()){
        vector<string> current_grid = q.front().first.first;
        vector<Action> current_actions = q.front().first.second;
        int moves_left = q.front().second;
        q.pop();
        if(goal_test(current_grid)==0)
            return current_actions;
        if(moves_left < goal_test(current_grid))
            continue;
        vector<Action> neighbours = generateActions(current_grid);
        
        for(int i=0;i<neighbours.size();i++){
            vector<string> new_grid (current_grid);
            perform_action(new_grid, neighbours[i]);
            vector<Action> new_actions (current_actions);
            new_actions.push_back(neighbours[i]);
            if(visited.find(make_pair(new_grid, neighbours[i])) != visited.end())
                continue;
            visited.insert(make_pair(new_grid, neighbours[i]));
            q.push(make_pair(make_pair(new_grid, new_actions), moves_left-1));
        }
    }
    return actions;
}

void print_grids(vector<string> &grid1, vector<string> &grid2){
    cout<< ". ";
    for(int j=0;j<grid1[0].size()-1;j++){
        cout << j%10 << " ";
    }
    cout<< "     . ";
    for(int j=0;j<grid2[0].size()-1;j++){
        cout << j%10 << " ";
    }
    cout << endl;
    for (int i = 0; i < grid1.size(); i++) {
        cout << i%10 << " ";
        for(int j=0;j<grid1[i].size()-1;j++){
            cout << grid1[i][j] << " ";
        }
        if(i==grid1.size()/2)
            cout << " -->  ";
        else
            cout << "      ";
        cout <<i%10 << " ";
        for(int j=0;j<grid2[i].size()-1;j++){
            cout << grid2[i][j] << " ";
        }
        cout << endl;
    }
    cout<<endl;
}

int main(int argc, char* argv[]) {
    int num_moves = stoi(argv[1]);
    string line;
    vector<string> grid;
    string fname = argv[2];
    ifstream inputFile(fname);
    while (getline(inputFile, line)) {
        string line2 = line;
        if(line2.length()%2==1)
            line2+="\n";
        grid.push_back(line2);
    }
    inputFile.close();
    grid.pop_back();

    moves.push_back('L');
    moves.push_back('R');
    moves.push_back('U');
    moves.push_back('D');

    vector<Action> actions = bfs(grid, num_moves);
    if(actions.size() == 0)
        cout << "No solution found"<<endl;
    else{
        cout<<endl<<"--------Stepwise output--------"<<endl<<endl;
        vector<string> current_grid = grid;
        for(int i=0;i<actions.size();i++){
            cout<<i+1<<". ";
            print_action(actions[i]);
            cout<<endl;
            vector<string> new_grid (current_grid);
            perform_action(new_grid, actions[i]);
            print_grids(current_grid, new_grid);
            current_grid = new_grid;
            cout<<endl;
        }

        cout<<"--------Final output--------"<<endl<<endl;
        print_grid(grid);
        for (int i = 0; i < actions.size(); i++){
            cout<<i+1<<". ";
            print_action(actions[i]);
        }
        cout<<endl;
    }
    
    return 0;
}