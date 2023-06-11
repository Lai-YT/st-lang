var i: int := 0
var a: int := 1
var b: int := 2

procedure p(a: int, b: int)
  if a < 0 or b < 0 then
    return
  end if
  i := a + b
end p

% p not invoked, no change
put i
