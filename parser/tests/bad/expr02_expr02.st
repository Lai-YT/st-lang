%
% 2 errors of EXPR02:
%   operand of 'sign' operation must have type 'int' or 'real'
%
% This is to make sure our test case covers all branches
%

var i: int

% positive
i := +"string"

% negative
i := -"string"
