% 'function' must ends with a 'result' statement
%   has result but end with declaration

function f(var i: int) : int
  result i
  const j := i
end f
