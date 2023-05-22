%
% 2 errors of EXPR06:
%   range of a 'for' statement must have type 'int'
%
% This is to make sure our test case covers all branches
%

% decreasing, id, begin
for decreasing i: 3.0..1
  % empty
end for

%   decreasing, id, end
for decreasing i: 3..1.0
  % empty
end for
