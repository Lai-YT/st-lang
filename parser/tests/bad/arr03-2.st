% type of an 'array' must be a 'static array'
%   dynamic formal

var upperBound: int

procedure p(arr: array 1..* of array 1..upperBound of int)
  % empty
end procedure
