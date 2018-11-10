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
int: max_time = if del_add > del_mul then del_add else del_mul endif * n;
array[1..n] of var int: all_starting_times;
array[1..length(add)] of var 0..max_time: add_starting_times;
array[1..length(mul)] of var 0..max_time: mul_starting_times;

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

% Used number of adders/multipliers
array[1..length(add)] of var 1..number_add: used_number_add;
array[1..length(mul)] of var 1..number_mul: used_number_mul;

% Clock cycles
var int: clock_cycles;

% Constraints

% Set all_starting_times, all_task_delays and all_execution_resources
constraint
  forall(i in 1..length(add)) (
    all_starting_times[add[i]] = add_starting_times[i] /\
    all_task_delays[add[i]] = add_task_delays[i] /\
    all_execution_resources[add[i]] = add_execution_resources[i]
  ) /\
  forall(i in 1..length(mul)) (
    all_starting_times[mul[i]] = mul_starting_times[i] /\
    all_task_delays[mul[i]] = mul_task_delays[i] /\
    all_execution_resources[mul[i]] = mul_execution_resources[i]
  )
;

% Precedence constraints
constraint
  forall(i in 1..n, j in dependencies[i]) (
    all_starting_times[i] + all_task_delays[i] <= all_starting_times[j]
  )
;

constraint forall(i in index_set(last)) (
  all_starting_times[last[i]] + all_task_delays[last[i]] <= clock_cycles
);

% Resource constraints
constraint
  diffn(add_starting_times, used_number_add, add_task_delays, add_execution_resources) /\
  diffn(mul_starting_times, used_number_mul, mul_task_delays, mul_execution_resources) /\
  cumulative(add_starting_times, add_task_delays, add_execution_resources, number_add) /\
  cumulative(mul_starting_times, mul_task_delays, mul_execution_resources, number_mul)
;

% Solve problem
solve :: int_search(all_starting_times, first_fail, indomain_min, complete) minimize clock_cycles;

output
[
  "All starting times:\n" ++ show(all_starting_times) ++
  "\nAdd starting times:\n" ++ show(add_starting_times) ++
  "\nMul starting times:\n" ++ show(mul_starting_times) ++
  "\nAll task delays:\n" ++ show(all_task_delays) ++
  "\nAdd task delays:\n" ++ show(add_task_delays) ++
  "\nMul task delays:\n" ++ show(mul_task_delays) ++
  "\nAll task delays:\n" ++ show(all_execution_resources) ++
  "\nAdd execution resources:\n" ++ show(add_execution_resources) ++
  "\nMul execution resources:\n" ++ show(mul_execution_resources) ++
  "\nUsed number of adders:\n" ++ show(used_number_add) ++
  "\nUsed number of multipliers:\n" ++ show(used_number_mul) ++
  "\nClock cycles:\n" ++ show(clock_cycles)
];