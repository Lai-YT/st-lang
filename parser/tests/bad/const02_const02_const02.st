%
% 3 errors of CONST02:
%   re-assignment on constant reference
%
% This is to make sure our test case covers all branches
%

% constant parameter
procedure p(i: int, n: int)
  i := n
end p

% identifier
begin
  const i := 0
  i := 1
end

% array subscript
begin
  var arr: array 1..2 of int
  const constArr := arr
  constArr[1] := 0
end
