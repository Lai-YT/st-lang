%
% 2 errors of STR03:
%   max length of a 'string' must be in range 1 ~ 255
%
% This is to make sure our test case covers all branches
%

% non-positive length
var str1: string(0)

% length exceed limit
var str2: string(256)
