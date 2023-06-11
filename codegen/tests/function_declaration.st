var n: int := -1

function abs(n: int): int
  if n < 0 then
    result -n
  end if
  result +n
end abs

put n
