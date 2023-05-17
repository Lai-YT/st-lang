% a 2x2 int array
var arr: array 1..2 of array 1..2 of int

% array subscript as lhs
% arr values:
%  | 1 | 2 |
%  |---|---|
%  | 3 | 4 |
arr[1][1] := 1
arr[1][2] := 2
arr[2][1] := 3
arr[2][2] := 4

% array as rhs
const constArr := arr
% constant array subscript as rhs
% arr values:
%  | 4 | 3 |
%  |---|---|
%  | 2 | 1 |
arr[1][1] := constArr[2][2]
arr[1][2] := constArr[2][1]
arr[2][1] := constArr[1][2]
arr[2][2] := constArr[1][1]
