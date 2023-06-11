var n: int


function add(var a: int, var b: int) : int
  a := a + b
  result a
end add

function fibonacciNumber(n: int): int
  if n < 0 then
    put "n must not be negative"
    result -1
  end if
  if n < 2 then
    result n
  end if
  result add(fibonacciNumber(n - 1), fibonacciNumber(n - 2))
end fibonacciNumber

% puts the global variable `n`
procedure putN()
  put n
end putN

n := fibonacciNumber(10)
putN()
