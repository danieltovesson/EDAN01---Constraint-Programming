include "globals.mzn";

% Input variables
int: graph_size;
int: start;
int: n_dests;
array[1..n_dests] of 1..graph_size: dest;
int: n_edges;
array[1..n_edges] of 1..graph_size: from;
array[1..n_edges] of 1..graph_size: to;
array[1..n_edges] of int: cost;

% Create adjacency matrix
array[1..graph_size, 1..graph_size] of var -1..max(cost): adjacency_matrix = array2d(1..graph_size, 1..graph_size,
  [
    if sum(
      [
        if (i == from[k] /\ j == to[k]) \/ (i == to[k] /\ j == from[k])
          then cost[k]
          else 0
        endif
        | k in 1..n_edges
      ]
    ) > 0
      then sum(
      [
        if (i == from[k] /\ j == to[k]) \/ (i == to[k] /\ j == from[k])
          then cost[k]
          else 0
        endif
        | k in 1..n_edges
      ])
      else
        if (i == start /\ has_element(j , dest)) \/ (has_element(i , dest) /\ j == start)
          then -1
          else 0
        endif
      endif
    | i in 1..graph_size, j in 1..graph_size
  ]
);

% Decision variables
array[1..graph_size, 1..graph_size] of var 0..1: adjacency_matrix_used;
array[1..n_dests, 1..graph_size] of var 1..graph_size: subcircuits;
array[1..n_dests, 1..graph_size] of var 0..graph_size: paths;
array[1..n_dests, 1..graph_size] of var -1..max(cost): path_costs;
array[1..n_dests] of var 1..graph_size-1: path_lengths;
var int: total_cost;

% Constraint to subcircuits
constraint
  forall(i in 1..n_dests) (
    subcircuit([subcircuits[i, j] | j in 1..graph_size])
  )
;

% Constraint each subcircuit value with a corresponding cost 
constraint
  forall(i in 1..n_dests, j in 1..graph_size) (
    element(
      subcircuits[i, j],
      [adjacency_matrix[j, k] | k in 1..graph_size],
      path_costs[i, j]
    )
  )
;

% Make sure no forbidden paths can be traversed and that nodes can go to themselves
constraint
  forall(i in 1..n_dests, j in 1..graph_size, k in 1..graph_size) (
    if adjacency_matrix[j, k] == 0 /\ j != k
      then subcircuits[i, j] != k
    endif
  )
;

% Constraint so that it can't traverse from start node directly to destination nodes
constraint
  forall(i in 1..n_dests, j in 1..n_dests) (
    path_costs[i, start] != -1
  )
;

% Make sure start node is included in path
constraint
  forall(i in 1..n_dests) (
    subcircuits[i, start] != start
  )
;

% Make sure destination nodes are included in path
constraint
  forall(i in 1..n_dests) (
    subcircuits[i, dest[i]] = start
  )
;

% Calculate the length of the path
constraint
  forall(i in 1..n_dests) (
    path_lengths[i] = sum([if subcircuits[i, j] != j then 1 else 0 endif | j in 1..graph_size])
  )
;

% Construct the path
constraint
  forall(i in 1..n_dests) (
    paths[i, 1] = start
  )
;
constraint
  forall(i in 1..n_dests, j in 1..path_lengths[i]-1) (
    paths[i, j+1] = subcircuits[i, paths[i, j]]
  )
;

% Setup used path matrix
constraint
  forall(i in 1..n_dests, j in 1..graph_size) (
    if j != subcircuits[i, j]
      then adjacency_matrix_used[j, subcircuits[i, j]] = 1 /\ adjacency_matrix_used[subcircuits[i, j], j] = 1
    endif
  )
;

% Sum total cost
constraint total_cost =
  sum(
    [
      if adjacency_matrix_used[i, j] == 1 /\ adjacency_matrix[i, j] != -1
        then adjacency_matrix[i, j]
        else 0
      endif
      | i in 1..graph_size, j in 1..graph_size
    ]
  ) / 2
;

% Minimize the total cost 
solve minimize total_cost;

% Print result
output
  ["Graph:\n"] ++ [show2d(adjacency_matrix)] ++
  ["Graph used:\n"] ++ [show2d(adjacency_matrix_used)] ++
  ["Subcircuits:\n"] ++ [show2d(subcircuits)] ++
  ["Paths:\n"] ++ [show2d(paths)] ++
  ["Path lengths: " ++ show(path_lengths)] ++
  ["\nPath costs:\n"] ++ [show2d(path_costs)] ++
  ["Total cost: " ++ show(total_cost)];