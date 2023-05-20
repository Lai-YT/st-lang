const n: real := 1.0
var i: int := 1
procedure p(n: int)
  % the parameter n shadows the outer n, which has un-assignable type
  % so no type error
  i := n
end p
