function func(
  arrOfDynamicString: array 1..2 of string(1),
  var dynamicArrayOfDynamicString: array 1..* of string(*)
): string
  result "some string"
end func

procedure proc1
  var decl1 := "this is a declaration"
  decl1 := "this is a statement"
  const decl2 := "this is another declaration"
  decl1 := "this is another statement"
  return
end proc1

var arrayOfStrings: array 1..2 of string(1)
const functionCallIsAnExpr := func(arrayOfStrings, arrayOfStrings)
proc1  % procedure call is a statement

function funcThatTakesNoParameter: int
  result 0
end funcThatTakesNoParameter

const i := funcThatTakesNoParameter
