include "globals.mzn";

int: n;
int: n_commercial;
int: n_residential;
array[int] of int: point_distribution;

% Decision variables
array[1..n, 1..n] of var 0..1: grid;
array[1..n] of var int: n_residential_row;
array[1..n] of var int: n_residential_col;
var int: cost;

% Constraints

% Make sure the correct amount of commercial and residential lots are in the grid
constraint sum([if grid[i, j] == 0 \/ grid[j, i] == 0 then 1 else 0 endif | i in 1..n, j in 1..n]) = n_commercial;
constraint sum([if grid[i, j] == 1 \/ grid[j, i] == 1 then 1 else 0 endif | i in 1..n, j in 1..n]) = n_residential;

% Count the number of commercial and resideltial lots in each row and column
constraint
  forall(i in 1..n) (
    n_residential_row[i] = sum([grid[i, j] | j in 1..n]) /\
    n_residential_col[i] = sum([grid[j, i] | j in 1..n])
  )
;

% Calculate the cost
constraint cost =
  sum([point_distribution[n_residential_row[i]] | i in 1..n]) +
  sum([point_distribution[n_residential_col[i]] | i in 1..n]);

% Add symmetry breaking constraint
constraint lex2(grid);

% Solve the problem
solve maximize cost;

output
[
  "Cost: " ++ show(cost) ++
  "\nNumber of residential row:\n" ++ show(n_residential_row) ++
  "\nNumber of residential column:\n" ++ show(n_residential_col) ++
  "\nGrid:\n" ++ show2d(grid)
];