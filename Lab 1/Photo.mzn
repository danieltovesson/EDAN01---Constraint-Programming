include "globals.mzn";

% Number of people
int: n = 9;

% Number of preferences
int: n_prefs = 17;

% Preferences
array[1..n_prefs, 1..2] of var int : prefs = [| 1,3 | 1,5 | 1,8 | 2,5 | 2,9 |
                                          3,4 | 3,5 | 4,1 | 4,5 | 5,6 |
                                          5,1 | 6,1 | 6,9 | 7,3 | 7,8 |
                                          8,9 | 8,7 |];

output[show(prefs)];