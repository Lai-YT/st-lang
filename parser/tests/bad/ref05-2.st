% 'n'-dimensional 'array' cannot have 'm' subscripts
%   variable array

% 2-dimensional
var a: array 1..2 of array 1..2 of int
const c := a[1][2][3]
