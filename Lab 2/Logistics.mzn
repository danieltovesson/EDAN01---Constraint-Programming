include "globals.mzn";

% Get input from user (prefix is for parameter input field order)
int: a_graph_size;
int: b_start;
int: c_n_dest;
array[1..n_dest] of 1..graph_size: d_dest;
int: e_n_edges;
array[1..n_edges] of 1..graph_size: f_from;
array[1..n_edges] of 1..graph_size: g_to;
array[1..n_edges] of int: h_cost;

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
array[1..graph_size, 1..graph_size] of int: adjacency_matrix = array2d(1..graph_size, 1..graph_size,
 [
   sum(
     [
       if (from[k] == i /\ to[k] == j) \/ (to[k] == i /\ from[k] == j)
         then cost[k]
         else 0
       endif
       | k in 1..n_edges]
   )
   | i in 1..graph_size, j in 1..graph_size
 ]
); 

% Decision variables
array[1..graph_size] of var 1..graph_size: path;
array[1..graph_size-1] of var 1..max(cost): path_costs;
var int: total_cost;

constraint subcircuit(path);

constraint path[1] = start;

constraint path[graph_size] = 6;

constraint
  forall(i in 1..graph_size-1) (
    adjacency_matrix[path[i], path[i+1]] != 0
  )
;

constraint
  forall(i in 1..graph_size-1) (
    path_costs[i] = adjacency_matrix[path[i], path[i+1]]
  )
;
  
constraint total_cost = sum([path_costs[i] | i in 1..graph_size-1]);

% Minimize the total cost 
solve minimize total_cost;

% Print result
output[
  "Path: " ++ show(path) ++
  "\nPath costs: " ++ show(path_costs) ++
  "\nTotal cost: " ++ show(total_cost) ++
  "\nGraph: " ++ show(adjacency_matrix)
]