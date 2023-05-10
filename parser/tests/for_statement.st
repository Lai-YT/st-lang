var j := 0
for i: 1..5
  j := i
end for

for decreasing i: 1..5
  j := i
end for

for decreasing : 1..5
  % empty
end for

for : 1..5
  for : 1..5
    exit when true
  end for
end for
