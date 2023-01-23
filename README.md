# Rat-in-a-Maze-Assambly

solving the rat in a maze problem with Assembly

We have discussed Backtracking and Knight’s tour problem in Set 1. Let us discuss Rat in a Maze as another example problem that can be solved using Backtracking.

A Maze is given as N*N binary matrix of blocks where source block is the upper left most block i.e., maze[0][0] and destination block is lower rightmost block i.e., maze[N-1][N-1]. A rat starts from source and has to reach the destination. The rat can move only in two directions: forward and down. 

In the maze matrix, 0 means the block is a dead end and 1 means the block can be used in the path from source to destination. Note that this is a simple version of the typical Maze problem. For example, a more complex version can be that the rat can move in 4 directions and a more complex version can be with a limited number of moves.

# Example:
 Gray blocks are dead ends (value = 0).

![image](https://user-images.githubusercontent.com/84382080/214054093-1fbd37b0-62d0-419e-b413-d0d4687e42fe.png)

Following is a binary matrix representation of the above maze:

{1, 0, 0, 0}

{1, 1, 0, 1}

{0, 1, 0, 0}

{1, 1, 1, 1}

Following is a maze with highlighted solution path.

![image](https://user-images.githubusercontent.com/84382080/214054213-4e3d2c69-5e7d-44cb-b0cd-b6e661994a7c.png)

Following is the solution matrix (output of program) for the above input matrix:

{1, 0, 0, 0}

{1, 1, 0, 0}

{0, 1, 0, 0}

{0, 1, 1, 1}

All entries in solution path are marked as 1.

# Approach: 
Form a recursive function, which will follow a path and check if the path reaches the destination or not. If the path does not reach the destination then backtrack and try other paths. 
