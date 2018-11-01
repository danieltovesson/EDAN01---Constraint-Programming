include "globals.mzn";

% Specify number of items
int: num_items = 8;

% Create items array
array[1..num_items, 1..4] of int: items = array2d(1..num_items, 1..4,
[
% sodium    fat   calories   cost (cent)
   50,      17,   220,       25,  % Beef Patty
  330,       9,   260,       15,  % Bun
  310,       6,    70,       10,  % Cheese
    1,       2,    10,        9,  % Onions
  260,       0,     5,        3,  % Pickles
    3,       0,     4,        4,  % Lettuce
  160,       0,    20,        2,  % Ketchup
    3,       0,     9,        4,  % Tomato
]);

% Create names array
array[1..num_items] of string: names = ["Beef Patty ",
                                        "Bun        ",
                                        "Cheese     ",
                                        "Onion      ",
                                        "Pickles    ",
                                        "Lettuce    ",
                                        "Ketchup    ",
                                        "Tomato     "];

% Specify number of limits
int: num_limits = 3;

% Create limits array
array[1..num_limits] of int: limits = [3000, 150, 3000]; % sodium, fat, calories

% Decision variables
array[1..num_items] of var 1..5: x;

% References to ingredients keys
int: BeefPatty = 1;
int: Bun       = 2;
int: Cheese    = 3;
int: Onions    = 4;
int: Pickles   = 5;
int: Lettuce   = 6;
int: Ketchup   = 7;
int: Tomato    = 8;

constraint
   % sodium < 3000mg, fat < 150g, calories < 3000
   forall(j in 1..num_limits) (
     % Sum each and make sure it does not exceed limit
     sum([x[i]*items[i,j] | i in 1..num_items]) < limits[j]
   )

   % Keep the serving of ketchup and lettuce the same.
   /\ x[Ketchup] = x[Lettuce]

   % Keep the servings of pickles and tomatoes the same.
   /\ x[Pickles] = x[Tomato]
;

solve maximize total;

% Calculate total by multiplying the decided number with the cost and sum all
var int: total = sum([x[i]*items[i,4] | i in 1..num_items]);

output [
  "total   : ", show(total), " cent\n",
  "sodium  : ", show(sum([x[i]*items[i,1] | i in 1..num_items])), " mg\n",
  "fat     : ", show(sum([x[i]*items[i,2] | i in 1..num_items])), " g\n",
  "calories: ", show(sum([x[i]*items[i,3] | i in 1..num_items])), "\n",
  "x       : ", show(x), "\n",
]
++
[
  show(names[i]) ++ ": " ++ show(x[i]) ++ " (" ++ show_int(3,x[i]*items[i,4]) ++ " cent)\n"
  | i in 1..num_items
]
;
