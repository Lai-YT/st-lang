%
% 4 errors of SUB02:
%   'function' must ends with a 'result' statement
%
% This is to make sure our test case covers all branches
%

% has result but end with statement
function f1(var n: int) : int
  result n
  n := 1
end f1

% has result but end with declaration
function f2(var n: int) : int
  result n
  const j := n
end f2

% no result
function f3(var n: int) : int
  n := 0
end f3

% empty
function f4(var n: int) : int
end f4
