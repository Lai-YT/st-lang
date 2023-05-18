% a constant identifier cannot be a 'dynamic array'
%   no specified type

var upperBound := 2
var dynamicArr: array 1..upperBound of int
const constArr := dynamicArr
