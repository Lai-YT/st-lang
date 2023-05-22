loop
  exit when (not true) or (5 mod 5 not= 0)
end loop

const isFalse := false
if true then
  loop
    exit when isFalse
  end loop
end if
