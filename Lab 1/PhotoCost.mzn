include "globals.mzn";

% Get input from user
int: n; % Number of people
int: n_prefs; % Number of preferences
array[1..n_prefs, 1..2] of 1..n: prefs; % Preferences

% Decision variables
array[1..n] of var 1..n: seq; % Sequence of persons
array[1..n] of var 1..n: indexes; % Indexes for each person
array[1..n_prefs] of var 0..1: fulfilled; % Fulfilled preferences (1=fulfulled, 0=unfulfilled)
var 0..n_prefs: cost; % Used to maximize the cost (highest number of fulfilled preferences)

% Constraints
constraint
  alldifferent(seq) /\ % Make sure all people are different
  forall(i in 1..n) (
    % Populate array so that index for each person is accessible
    indexes[i] = sum([if seq[j] == i then j else 0 endif | j in 1..n])
  ) /\
  forall(i in 1..n_prefs) (
    % Tries to put the people with max distance between each other
    if abs(indexes[prefs[i, 1]] - indexes[prefs[i, 2]]) = 1 
      then fulfilled[i] = 1
      else fulfilled[i] = 0
    endif
  ) /\
  cost = sum([fulfilled[i] | i in 1..n_prefs]) % Counts the number of fulfilled preferences
;

% Solve problem
solve maximize cost; % Ask for the highest cost possible

% Print result
output ["Sequence: " ++ show(seq) ++ "\nCost: " ++ show(cost)]