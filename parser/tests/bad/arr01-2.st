% lower bound of an 'array' must be determined at compile-time
%   dynamic formal

var lowerBound := 1

procedure p(arr: array lowerBound..* of int)
  % empty
end procedure
