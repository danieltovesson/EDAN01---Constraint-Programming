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
array[1..graph_size] of var int: path;
array[1..graph_size-1] of var int: path_cost;
var int: total_cost;
var int: total_traceback;

% Function for getting a path through the adjacency matrix
function array[int] of var int: path(array[int,int] of int: adjacency_matrix, int: start, array[int] of int: dest) =
let {
    set of int: V = index_set_1of2(adjacency_matrix);
    array[1..graph_size] of var (V union {-1}): path_array;
    var 1..graph_size: n_nodes;

    % Make sure the path array starts with the start symbol
    constraint path_array[1] == start;
    
    % Make sure the last node is one of the destination nodes
    constraint sum([if path_array[n_nodes] == dest[i] then i else 0 endif | i in 1..n_dest]) != 0;
    
    % Make sure the path array contains all the destination nodes
    constraint forall(i in 1..n_dest) (
      sum([if path_array[j] == dest[i] then j else 0 endif | j in 2..n_nodes]) != 0
    );

    % Make sure the path is consistent with from-to
    constraint forall(i in 2..n_nodes) (adjacency_matrix[path_array[i-1], path_array[i]] > 0);

    % Give the last indexes in the path array the value -1 if the path size is smaller than the array size
    constraint forall(i in 1..graph_size where i > n_nodes) (path_array[i] = -1);
} in path_array;

% Get a path
constraint path = path(adjacency_matrix, start, dest);

% Calculate the path cost array
constraint
  forall(i in 1..graph_size-1) (
    if path[i+1] != -1
      then path_cost[i] = adjacency_matrix[path[i], path[i+1]]
      else path_cost[i] = 0
    endif
  )
;

% Calculate the traceback (where the path traversed back to the previous node)
constraint
  total_traceback = sum(
    [
      if path[i+2] != -1 /\ path[i] == path[i+2]
        then path_cost[i]
        else 0
      endif
      | i in 1..graph_size-2
    ]
  )
;

% Calculate the total cost for the whole path
constraint total_cost = sum([path_cost[i] | i in 1..graph_size-1]);

% Minimize the cost to traverse through the paths 
solve minimize total_cost - total_traceback;

% Print result
output[
  "Path: " ++ show(path) ++
  "\nPath cost: " ++ show(path_cost) ++
  "\nTotal cost: " ++ show(total_cost) ++
  "\nTotal traceback: " ++ show(total_traceback) ++
  "\nSum: " ++ show(total_cost - total_traceback)
]