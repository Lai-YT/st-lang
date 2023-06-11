begin
  % const with type
  const i: int := 10
  put i

  % var with no type
  var j := i
  put j

  % var with no init expr
  var k: int
  k := 1
  put k

  % var with type & init expr
  var l: int := 2
  put l

  % const with type & run-time init expr
  const m: int := l
  put m

  % const with no type & run-time init expr
  const n := l
  put n

  % const string
  const s := "string"
  put s
end
