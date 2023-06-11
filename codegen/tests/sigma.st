% Sigma.st
%
% Compute sum = 1 + 2 + ... + n
%

% constant and variable declarations
const n: int := 10
var sum: int
var index: int

% with for statement
sum := 0
for index: 1 .. n
  sum := sum + index
end for
put "The result is ", sum

skip

% with loop statement
sum := 0
index := 1
loop
  sum := sum + index
  index := index + 1
  exit when index > n
end loop
put "The result is ", sum
