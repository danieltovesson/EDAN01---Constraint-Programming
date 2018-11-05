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

% TODO: needs to be created dynamically
array[1..graph_size, 1..graph_size] of int: adjacency_matrix = [|0, 4,  2, 0,   0, 0
                                                                |4, 0,  5, 10,  0, 0
                                                                |2, 5,  0, 0,   3, 0
                                                                |0, 10, 0, 0,   4, 11
                                                                |0, 0,  3, 4,   0, 0
                                                                |0, 0,  0, 11,  0, 0|];

% Decision variables
array[1..graph_size] of var int: path;
array[1..graph_size-1] of var int: path_cost;
var int: total_cost;

function array [int] of var int: path(array[int,int] of int: graph, int: source, int: target)::promise_total =
let {
    set of int: V = index_set_1of2(graph);
    int: order = card(V);
    set of int: indexes = 1..order;
    array[indexes] of var (V union {-1}): path_array;
    var indexes: path_nodes_count; % the 'size' of the path

    constraint assert(index_set_1of2(graph) = index_set_2of2(graph), "The adjacency matrix is not square", true);
    constraint assert({source, target} subset V, "Source and target must be vertexes", true);

    constraint path_array[1] == source;
    constraint path_array[path_nodes_count] == target;

    constraint forall(i in 2..path_nodes_count) (graph[ path_array[i-1], path_array[i] ] > 0);

    constraint forall(i in indexes where i > path_nodes_count) (path_array[i] = -1);

    constraint forall(i,j in indexes where i<j /\ j<=path_nodes_count) (path_array[i] != path_array[j]);
} in path_array;

constraint
  path = path(adjacency_matrix, start, 6) /\
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