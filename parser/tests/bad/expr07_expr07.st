%
% 2 errors of EXPR07:
%   operand of 'mod' operation must have type 'int'
%
% This is to make sure our test case covers all branches
%

var i: int
i := 5 mod 2.0
i := 5.0 mod 2
