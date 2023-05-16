% 'n'-dimensional 'array' cannot have 'm' subscripts
%   constant array

% 2-dimensional
var a: array 1..2 of array 1..2 of int
const b := a
const c := b[1][2][3]
