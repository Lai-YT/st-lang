%
% 3 errors of CONST02:
%   re-assignment on constant reference
%
% This is to make sure our test case covers all branches
%

% identifier
const i := 0
i := 1

% array subscript
var arr: array 1..2 of int
const constArr := arr
constArr[1] := 0

% constant parameter
procedure p(i: int, n: int)
  i := n
end p
