function f(r: real, str: string(*), arr: array 1..* of int): bool
  result false
end f

var upperBound := 4
var arr: array 1..upperBound of int
const b: bool := f(
  1, % int is assignable to real
  "any length",
  arr
)
