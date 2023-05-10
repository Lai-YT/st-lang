loop
  % empty
end loop

loop
  exit when true
end loop

% nested loop with exit statement
var i := 0
loop
  i := i + 1
  var j := 0
  loop
    j := j + 1
    exit when j = 5
  end loop
  exit when i = 5
end loop
