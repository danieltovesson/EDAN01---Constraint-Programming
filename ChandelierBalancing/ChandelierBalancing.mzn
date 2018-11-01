include "globals.mzn";

% Specify number of weights
int: n = 9;

% Specify constraint for weights
set of 1..n: R = 1..n;

% Create decision variables
var R: a;
var R: b;
var R: c;
var R: d;
var R: e;
var R: f;
var R: g;
var R: h;
var R: i;

constraint
  % All weights need to be different
  alldifferent([a, b, c, d, e, f, g, h, i]) /\
  % Left arm constraint
  (2*a = 1*b+2*c) /\
  % Top right arm constraint
  (2*d+1*e = 1*f) /\
  % Bottom right arm constraint
  (2*g+1*h = 3*i) /\
  % Left and right arm constraint
  3*(a+b+c) = 2*(d+e+f)+3*(g+h+i) 
;

solve satisfy;

output [
  show(["a", "b", "c", "d", "e", "f", "g", "h", "i"]) ++ "\n" ++
  show([a, b, c, d, e, f, g, h, i])
];