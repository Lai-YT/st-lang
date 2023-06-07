var i: int

i := 0
loop
  i := i + 1
  exit
end loop
put i

i := 0
loop
  exit when i > 5
  i := i + 1
end loop
put i
