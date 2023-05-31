loop
  exit when (not true) or (5 mod 5 not= 0)
end loop

if true then
  const isFalse := false
  loop
    exit when isFalse
  end loop
end if
