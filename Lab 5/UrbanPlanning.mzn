include "globals.mzn";

int: n;
int: n_commercial;
int: n_residential;
array[int] of int: point_distribution;

% Decision variables
array[1..n, 1..n] of var 0..1: grid;
var int: cost;

% Constraints

% Make sure the correct amount of commercial and residential lots are in the grid
constraint sum([if grid[i, j] == 1 then 1 else 0 endif | i in 1..n, j in 1..n]) = n_commercial;
constraint sum([if grid[i, j] == 0 then 1 else 0 endif | i in 1..n, j in 1..n]) = n_residential;

solve maximize cost;

output
[
  "Cost: " ++ show(cost) ++
  "\nGrid:\n" ++ show2d(grid)
];