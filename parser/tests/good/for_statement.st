% increasing, no id, exit
var i := 0
for : 1..2
  i := i + 1
  % exit when i > 0
end for

% increasing, id
var j := 0
for k : 1..2
  j := k
end for

% decreasing, no id
var l := 0
for decreasing : 2..1
  l := l - 1
end for

% decreasing, id
var m := 0
for decreasing n : 2..1
  m := n
end for
