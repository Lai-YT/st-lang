%
% 2 errors of SUB01:
%   the name after 'end' should be the name of the 'subprogram'
%
% This is to make sure our test case covers all branches
%

% procedure
procedure p(i: int)
  % empty
end q

% function
function f(i: int): int
  % empty
  result i
end g
