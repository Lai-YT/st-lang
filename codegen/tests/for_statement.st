put "increasing, no id:"
for : 0..5
  put "." ..
end for
skip
put "^^^^^^ (6 dots)"

put "decreasing, no id:"
for decreasing : 5..0
  put "." ..
end for
skip
put "^^^^^^ (6 dots)"

put "increasing, with id:"
for i : 0..5
  put "." ..
end for
skip
put "^^^^^^ (6 dots)"

put "decreasing, with id:"
for decreasing i : 5..0
  put "." ..
end for
skip
put "^^^^^^ (6 dots)"

put "nested:"
put "x6"
for : 0..5
  put "  " ..
  for decreasing : 5..0
    put "." ..
  end for
  skip
  put "  ^^^^^^ (6 dots)"
end for
