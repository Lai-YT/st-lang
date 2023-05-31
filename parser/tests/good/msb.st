
var n: int
var msb: int
var m := n
get n
loop
  msb := m mod 10
  m := m / 10
  var isMsb := m = 0
  exit when isMsb
end loop

put "the most significant bit of ", n, "is ", msb
