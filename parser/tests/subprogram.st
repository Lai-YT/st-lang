function func1(
  arrOfDynamicString: array 1..2 of string(1),
  dynamicArrayOfDynamicString: array 1..* of string(*)
): string
  result "some string"
end func1

procedure func2
  var decl1 := "this is a declaration"
  decl1 := "this is a statement"
  const decl2 := "this is another declaration"
  decl1 := "this is another statement"
  return
end func2
