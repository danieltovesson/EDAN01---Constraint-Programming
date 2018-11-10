include "globals.mzn";
include "diffn.mzn";

% Data input
int: del_add;
int: del_mul;
int: number_add;
int: number_mul;
int: n;
set of int: last;
set of int: add;
set of int: mul;
array[1..n] of set of int: dependencies;

% Decision variables

% Starting times
array[1..n] of var int: all_starting_times;
array[1..length(add)] of var int add_starting_times;
array[1..length(mul)] of var int mul_starting_times;

% Task delays
int: max_del = if del_add > del_mul then del_add else del_mul endif;
array[1..n] of var 1..max_del: all_task_delays;
array[1..length(add)] of var int: add_task_delays = [del_add | i in 1..length(add)];
array[1..length(mul)] of var int: mul_task_delays = [del_mul | i in 1..length(mul)];

% Execution resources
int: max_number = if number_add > number_mul then number_add else number_mul endif;
array[1..n] of var 1..max_number: all_execution_resources;
array[1..length(add)] of var 1..number_add: add_execution_resources;
array[1..length(mul)] of var 1..number_mul: mul_execution_resources;

% Constraints

% Set all_starting_times, all_task_delays and all_execution_resources
constraint
  forall(i in 1..n) (
    
  )
;

% Precedence constraints
constraint
  forall(i in 1..n) (
    if length(dependencies[i]) == 2
      then tasks[dependencies[i][1]] + task_delays[dependencies[i][1]] <= tasks[dependencies[i][2]]
    endif
  )
;

% Resource constraints
%constraint