% type of the actual parameter cannot be assigned as type of the formal parameter

function f(i: int, r: real, s: string) : int
  result i
end f

const i := f("1", 2.0, "3")
