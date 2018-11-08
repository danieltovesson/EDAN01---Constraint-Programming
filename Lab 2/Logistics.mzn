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
   if (i == 1 /\ j == 6) \/ (i == 6 /\ j == 1)
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
array[1..graph_size] of var 1..graph_size: subcircuit;
array[1..graph_size] of var 0..graph_size: path;
array[1..graph_size] of var -1..max(cost): path_costs;
var 1..graph_size-1: path_length;
var int: total_cost;

% Constraint path so a subcircuit
constraint subcircuit(subcircuit);

% Constraint each subcircuit value with a corresponding cost 
constraint
  forall(i in 1..graph_size) (
    element(
      subcircuit[i],
      [adjacency_matrix[i, j] | j in 1..graph_size],
      path_costs[i]
    )
  )
;

% Make sure no forbidden paths can be traversed and make sure nodes can go to themselves
constraint
  forall(i in 1..graph_size, j in 1..graph_size) (
    if adjacency_matrix[i, j] == 0 /\ i != j
      then subcircuit[i] != j
    endif
  )
;

% Constraint start and destination of path
constraint subcircuit[start] != start;
constraint subcircuit[start] != 6;

% Calculate the length of the path
constraint path_length = sum([if subcircuit[i] != i then 1 else 0 endif | i in 1..graph_size]);

% Construct the path
constraint
  forall(i in 1..path_length) (
    path[i+1] = subcircuit[path[i]]
  )
;

% Sum total cost
constraint total_cost = sum([if path_costs[i] != -1 then path_costs[i] else 0 endif | i in 1..graph_size]);

% Minimize the total cost 
solve minimize total_cost;

% Print result
output[
  "Subcircuit: " ++ show(subcircuit) ++
  "\nPath: " ++ show(path) ++
  "\nPath length: " ++ show(path_length) ++
  "\nPath costs: " ++ show(path_costs) ++
  "\nTotal cost: " ++ show(total_cost) ++
  "\nGraph: " ++ show(adjacency_matrix)
]