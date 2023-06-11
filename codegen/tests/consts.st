% all compile-time constants, should not produce any code

% globals
const i: int := 0
const b := true
const s: string := "string"

put i
put b
put s
skip

% locals
begin
  const i: int := 0
  const b := true
  const s: string := "string"

  put i
  put b
  put s
end
