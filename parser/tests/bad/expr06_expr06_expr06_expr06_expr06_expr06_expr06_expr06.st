%
% 8 errors of EXPR06:
%   operand of 'arithmetic' operation must have type 'int' or 'real'
%
% This is to make sure our test case covers all branches
%

% when error occurs in an 'arithmetic' operation,
% the result expression is recovered to have type 'int'
var i: int

% addition
%   NOTE: string trigger string concatenation, so not using string here
i := false + 1
i := 1 + false

% subtraction
i := "string" - 1
i := 1 - "string"

% multiplication
i := "string" * 1
i := 1 * "string"

% division
i := "string" / 1
i := 1 / "string"
