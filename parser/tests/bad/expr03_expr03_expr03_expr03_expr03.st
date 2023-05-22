%
% 5 errors of EXPR03:
%   operand of 'boolean' operation must have type 'bool'
%
% This is to make sure our test case covers all branches
%

var b: bool

% and
b := 1 and true
b := true and 1

% or
b := 1 or true
b := true or 1

% not
b := not 1
