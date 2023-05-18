% type of the expression cannot be assigned to the reference
%   array type

var arr1: array 1..2 of array 1..3 of int
var arr2: array 1..2 of array 2..3 of int
%                             ^ mismatch
arr2 := arr1
