include "globals.mzn";

% Get input from user
int: graph_size = 6;
int: start = 1;
int: n_dest = 1;
array[1..n_dest] of 1..graph_size: dest = [6];
int: n_edges = 7;
array[1..n_edges] of 1..graph_size: from = [1,1,2,2,3,4,4];
array[1..n_edges] of 1..graph_size: to = [2,3,3,4,5,5,6];
array[1..n_edges] of int: cost = [4,2,5,10,3,4,11];

% Decision variables
var int: total_cost;
array[1..n_edges] of var 0..1: fulfilled;

constraint
  % Find all possible paths
  total_cost = sum([if fulfilled[i] == 1 then cost[i] else 0 endif | i in 1..n_edges])
;

% Solve problem
solve minimize total_cost;

% Print result
output ["Total cost: " ++ show(total_cost)]