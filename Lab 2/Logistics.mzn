include "globals.mzn";

% Get input from user
% int: graph_size = 6;
% int: start = 1;
% int: n_dest = 2;
% array[1..n_dest] of 1..graph_size: dest = [5,6];
% int: n_edges = 7;
% array[1..n_edges] of 1..graph_size: from = [1,1,2,2,3,4,4];
% array[1..n_edges] of 1..graph_size: to = [2,3,3,4,5,5,6];
% array[1..n_edges] of int: cost = [4,2,5,10,3,4,11];
int: graph_size = 6;
int: start = 1;
int: n_dest = 2;
array[1..n_dest] of 1..graph_size: dest = [5,6];
int: n_edges = 9;
array[1..n_edges] of 1..graph_size: from = [1,1,1,2,2,3,3,3,4];
array[1..n_edges] of 1..graph_size: to = [2,3,4,3,5,4,5,6,6];
array[1..n_edges] of int: cost = [6,1,5,5,3,5,6,4,2];

array[1..graph_size, 1..graph_size] of int: adjacency_matrix = array2d(1..graph_size, 1..graph_size,
 [
   sum(
     [if (from[k] == i /\ to[k] == j) \/ (to[k] == i /\ from[k] == j) then cost[k] else 0 endif | k in 1..n_edges]
   )
   | i in 1..graph_size, j in 1..graph_size
 ]
); 

% Decision variables
array[1..graph_size] of var int: path;
array[1..graph_size-1] of var int: path_cost;
var int: total_cost;

function array [int] of var int: path(array[int,int] of int: graph, int: start, array[int] of int: dest)::promise_total =
let {
    set of int: V = index_set_1of2(graph);
    int: order = card(V);
    set of int: indexes = 1..order;
    array[indexes] of var (V union {-1}): path_array;
    var indexes: path_nodes_count; % the 'size' of the path

    constraint path_array[1] == start;
    constraint sum([if path_array[path_nodes_count] == dest[i] then i else 0 endif | i in 1..n_dest]) != 0;
    constraint forall(i in 1..n_dest) (
      sum([if path_array[j] == dest[i] then j else 0 endif | j in 2..path_nodes_count]) != 0
    );

    constraint forall(i in 2..path_nodes_count) (graph[path_array[i-1], path_array[i]] > 0);

    constraint forall(i in indexes where i > path_nodes_count) (path_array[i] = -1);

    constraint forall(i,j in indexes where i<j /\ j<=path_nodes_count) (path_array[i] != path_array[j]);
} in path_array;

constraint
  path = path(adjacency_matrix, start, dest) /\
  forall(i in 1..graph_size-1) (
    if path[i+1] != -1
      then path_cost[i] = adjacency_matrix[path[i], path[i+1]]
      else path_cost[i] = 0
    endif
  ) /\
  total_cost = sum([path_cost[i] | i in 1..graph_size-1])
;

% Solve problem
solve minimize total_cost;

% Print result
output ["Total cost: " ++ show(total_cost) ++ "\nPath: " ++ show(path) ++ "\nPath cost: " ++ show(path_cost)]