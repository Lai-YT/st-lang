% re-assignment on constant reference
%   array subscript

var arr: array 1..2 of int
const constArr := arr
constArr[1] := 0
