%
% 2 errors of TYPE01:
%   type of the expression cannot be assigned to the reference
%
% This is to make sure our test case covers all branches
%

% scalar type
begin
  var i := 0
  var s := "0"
  s :=  i
end

% array type
begin
  var arr1: array 1..2 of array 1..3 of int
  var arr2: array 1..2 of array 2..3 of int
  %                             ^ mismatch
  arr2 := arr1
end
