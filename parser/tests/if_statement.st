var i := 0

% if-then
if not false then
  i := 1
end if

% if-then-else
if 1 > 2 then
  const j: int := i
else
  const j: int := 0
end if

const t: bool := (1 > 2)

% if-then with empty body
if false then
  % empty
end if

% if-then-else with empty body
if false then
  % empty
else
  % empty
end if
if false then
  % empty
else
  i := 1
end if

% nested if-then-else
if false then
  if false then
    const j: int := i
  else
    if false then
      const j: int := i
    else
      const j: int := 0
    end if
  end if
else
  if false then
    const j: int := i
  else
    const j: int := 0
  end if
end if
