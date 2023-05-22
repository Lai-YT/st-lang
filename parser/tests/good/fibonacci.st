% early return
function fibonacciNumber1(n: int): int
  if n < 0 then
    put "n must not be negative"
    result -1
  end if
  if n < 2 then
    result n
  end if
  result fibonacciNumber1(n - 1) + fibonacciNumber1(n - 2)
end fibonacciNumber1

% single exit point
function fibonacciNumber2(n: int): int
  var res: int
  if n < 0 then
    put "n must not be negative"
    res := -1
  else
    if n < 2 then
      res := n
    else
      res := fibonacciNumber2(n - 1) + fibonacciNumber2(n - 2)
    end if
  end if
  result res
end fibonacciNumber2

var n: int
var m: int
get n, m
put fibonacciNumber1(n)
put fibonacciNumber2(m)
