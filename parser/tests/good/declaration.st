% variable declarations
% no init expr
var i: int
% no type
var j := 1
% type + init expr
% var k: int := 1
% variable identifier as rhs
var l := i

% constant declarations
% no type
const m := 1
% type + init expr
% const n: int := 1
% variable identifier as rhs
const o := i
% compile-time constant identifier as rhs
const p := m
% run-time constant identifier as rhs
const q := o
