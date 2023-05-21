function fibonacciNumber(n: int): int
  if n < 0 then
    put "n must not be negative"
    result -1
  end if
  if n = 0 then
    result 0
  end if
  if n = 1 then
    result 1
  end if
  result fibonacciNumber(n - 1) + fibonacciNumber(n - 2)
end fibonacciNumber

var n: int
get n
put fibonacciNumber(n)
