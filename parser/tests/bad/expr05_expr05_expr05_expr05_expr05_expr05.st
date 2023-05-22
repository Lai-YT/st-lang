%
% 6 errors with EXPR05:
%   operands of 'comparison' operation must have the same type
%
% This is to make sure our test case covers all branches
%

var b: bool

% less than
b := 1.0 < 0

% greater than
b := 1.0 > 0

% equal to
b := 1.0 = 0

% less than or equal to
b := 1.0 <= 0

% greater than or equal to
b := 1.0 >= 0

% not equal to
b := 1.0 not= 0
