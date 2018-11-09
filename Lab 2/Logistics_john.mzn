include "globals.mzn";

% Input variables
int: graph_size;
int: start;
int: n_dests;
int: n_edges;

array[int] of int: dest;
array[int] of int: from;
array[int] of int: to;
array[int] of int: cost;


% Decision variables
array[1..n_dests, 1..graph_size] of var set of int: allPaths;
array[1..n_dests, 1..graph_size] of var int: subcircuitPath;
array[1..graph_size, 1..graph_size] of var 0 ..max(cost): nodesVisited;
array[1..graph_size] of var int: path_costs;
var int: total_cost; 

constraint
forall(i in 1..n_dests, j in 1..graph_size)
  ( allPaths[i, j] = 
    %kollar att alla noder inte har en edge till en annan?
    {to[edgeMove]   | edgeMove in 1..n_edges    where (from[edgeMove] == j) /\ from[edgeMove] != dest[i]}
    union
    %kollar att alla noder inte har en edge till en annan?
    {from[edgeMove]   | edgeMove in 1..n_edges    where (to[edgeMove] == j) /\ to[edgeMove] != dest[i]}
    union
    {start | edgeMove in 1..n_dests where (i == dest[j] )}
    union
    {edgeMove | edgeMove in 1..graph_size where (edgeMove != start /\ edgeMove != dest[i] /\ edgeMove == j)}
  );
  
  
% prepares for subcircuit
constraint forall(i in 1..n_dests, j in 1..graph_size)(
	subcircuitPath[i,j] in allPaths[i,j]
);

% find viable subcircuit based on nodes.
constraint forall (i in 1..n_dests)(
	subcircuit([subcircuitPath[i,j] | j in 1..graph_size])
);

% Create adjacency matrix (cost for different ways.)
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

% find what nodes we need to visit (costwise)
constraint forall(i in 1..n_dests, j in 1..graph_size)(
	nodesVisited[j,subcircuitPath[i,j]] = adjacency_matrix[j,subcircuitPath[i,j]]
);

% Create path costs array
constraint
  forall(i in 1..graph_size, j in 1..n_dests) (
    path_costs[i] = sum(j in 1..graph_size)(nodesVisited[i,j])
  )
;

% Sum total cost
constraint total_cost = sum([path_costs[i] | i in 1..graph_size-1]);

% Minimize the total cost 
solve minimize total_cost;

% Print result
output[
  "allPaths: \n" ++ show2d(allPaths) ++
  "\nsubcircuitPath: \n" ++ show2d(subcircuitPath) ++
  "\nvisited nodes: \n" ++ show2d(nodesVisited) ++
  "\nPath costs: " ++ show(path_costs) ++
  "\nTotal cost: " ++ show(total_cost) ++
  "\nGraph: \n" ++ show2d(adjacency_matrix)
]