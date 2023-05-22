%
% 12 errors with EXPR04:
%   operand of 'comparison' operation must have type 'int', 'real', or 'string'
%
% This is to make sure our test case covers all branches
%

var b: bool

% less than
b := true < 0
b := 0 < true

% greater than
b := true > 0
b := 0 > true

% equal to
b := true = 0
b := 0 = true

% less than or equal to
b := true <= 0
b := 0 <= true

% greater than or equal to
b := true >= 0
b := 0 >= true

% not equal to
b := true not= 0
b := 0 not= true
