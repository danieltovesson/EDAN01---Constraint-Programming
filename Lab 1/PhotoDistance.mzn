include "globals.mzn";

% Get input from user
int: n; % Number of people
int: n_prefs; % Number of preferences
array[1..n_prefs, 1..2] of 1..n: prefs; % Preferences

% Decision variables
array[1..n] of var 1..n: seq; % Sequence of persons
array[1..n_prefs] of var 0..1: fulfilled; % Fulfilled preferences (1=fulfulled, 0=unfulfilled)
var 0..n_prefs: cost; % Used to maximize the cost (highest number of fulfilled preferences)
var 0..n: minDistance; % Used to calculate the minimum distance

% Constraints
constraint
  alldifferent(seq) /\ % Make sure all people are different
  forall(i in 1..n_prefs) (
    % Tries to put the people with max distance between each other
    if abs(seq[prefs[i, 1]] - seq[prefs[i, 2]]) <= minDistance 
      then fulfilled[i] = 1
      else fulfilled[i] = 0
    endif
  ) /\
  cost = sum(i in 1..n_prefs) (fulfilled[i]) /\ % Counts the number of fulfilled preferences
  cost == n_prefs % Require the cost to be the same as the number of preferences
;

% Solve problem
solve minimize minDistance; % Ask for the lowest distance possible

% Print result
output ["Sequence: " ++ show(seq) ++ "\nMin distance: " ++ show(minDistance)]