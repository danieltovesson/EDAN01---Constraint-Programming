include "globals.mzn";

% Get input from user (prefix is for parameter input field order)
int: a_graph_size;
int: b_start;
int: c_n_dest;
array[1..c_n_dest] of 1..a_graph_size: d_dest;
int: e_n_edges;
array[1..e_n_edges] of 1..a_graph_size: f_from;
array[1..e_n_edges] of 1..a_graph_size: g_to;
array[1..e_n_edges] of int: h_cost;

% Input variables
int: graph_size = a_graph_size;
int: start = b_start;
int: n_dest = c_n_dest;
array[1..n_dest] of 1..graph_size: dest = d_dest;
int: n_edges = e_n_edges;
array[1..n_edges] of 1..graph_size: from = f_from;
array[1..n_edges] of 1..graph_size: to = g_to;
array[1..n_edges] of int: cost = h_cost;

% Create adjacency matrix
array[1..graph_size, 1..graph_size] of var int: adjacency_matrix;
constraint adjacency_matrix = array2d(1..graph_size, 1..graph_size,
 [
   if (i == start /\ has_element(j , dest)) \/ (has_element(i , dest) /\ j == start)
     then -1
     else
       sum(
         [
           if (i == from[k] /\ j == to[k]) \/ (i == to[k] /\ j == from[k])
             then cost[k]
             else 0
           endif
           | k in 1..n_edges
         ]
       )
     endif
   | i in 1..graph_size, j in 1..graph_size
 ]
); 

% Decision variables
array[1..n_dest, 1..graph_size] of var 1..graph_size: subcircuits;
array[1..n_dest, 1..graph_size] of var 0..graph_size: paths;
array[1..n_dest, 1..graph_size] of var -1..max(cost): path_costs;
array[1..n_dest] of var 1..graph_size-1: path_lengths;
var int: total_cost;

% Constraint to subcircuits
constraint
  forall(i in 1..n_dest) (
    subcircuit([subcircuits[i, j] | j in 1..graph_size])
  )
;

% Constraint each subcircuit value with a corresponding cost 
constraint
  forall(i in 1..n_dest, j in 1..graph_size) (
    element(
      subcircuits[i, j],
      [adjacency_matrix[j, k] | k in 1..graph_size],
      path_costs[i, j]
    )
  )
;

% Make sure no forbidden paths can be traversed and that nodes can go to themselves
constraint
  forall(i in 1..n_dest, j in 1..graph_size, k in 1..graph_size) (
    if adjacency_matrix[j, k] == 0 /\ j != k
      then subcircuits[i, j] != k
    endif
  )
;

% Constraint so that it can't traverse from start node directly to destination nodes
constraint
  forall(i in 1..n_dest, j in 1..n_dest) (
    subcircuits[i, start] != dest[j]
  )
;

% Make sure start node is included in path
constraint
  forall(i in 1..n_dest) (
    subcircuits[i, start] != start
  )
;

% Make sure destination nodes are included in path
constraint
  forall(i in 1..n_dest) (
    subcircuits[i, dest[i]] = start
  )
;

% Calculate the length of the path
constraint
  forall(i in 1..n_dest) (
    path_lengths[i] = sum([if subcircuits[i, j] != j then 1 else 0 endif | j in 1..graph_size])
  )
;

% Construct the path
constraint
  forall(i in 1..n_dest) (
    paths[i, 1] = start
  )
;
constraint
  forall(i in 1..n_dest, j in 1..path_lengths[i]-1) (
    paths[i, j+1] = subcircuits[i, paths[i, j]]
  )
;

% Sum total cost
constraint total_cost = sum([if path_costs[i, j] != -1 then path_costs[i, j] else 0 endif | i in 1..n_dest, j in 1..graph_size]);

% Minimize the total cost 
solve minimize total_cost;

% Print result
output
  ["Subcircuits:"] ++ [if j == 1 then "\n" else "" endif ++ show(j) ++ "->" ++ show(subcircuits[i, j]) ++ " " | i in 1..n_dest, j in 1..graph_size] ++
  ["\nPaths:"] ++ [if j == 1 then "\n" else "" endif ++ show(paths[i, j]) ++ " " | i in 1..n_dest, j in 1..graph_size] ++
  ["\nPath lengths: " ++ show(path_lengths)] ++
  ["\nPath costs:"] ++ [if j == 1 then "\n" else "" endif ++ show(path_costs[i, j]) ++ " " | i in 1..n_dest, j in 1..graph_size] ++
  ["\nTotal cost: " ++ show(total_cost)] ++
  ["\nGraph:"] ++ [if j == 1 then "\n" else "" endif ++ show(adjacency_matrix[i, j]) ++ " " | i in 1..graph_size, j in 1..graph_size];