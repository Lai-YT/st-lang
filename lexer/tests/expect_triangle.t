<VAR>
<identifier:s>
<ASSIGN>
<string:*>
1: var s := "*" % implicitly declaring s to be of type string
<LOOP>
2: loop
<PUT>
<identifier:s>
3:     put s
4:     % by default, the maximum length of a string is 255 characters
<EXIT>
<WHEN>
<identifier:length>
<'('>
<identifier:s>
<')'>
<'='>
<integer:1>
<integer:0>
5:     exit when length(s) = 10
<identifier:s>
<ASSIGN>
<identifier:s>
<'+'>
<string:*>
6:     s := s + "*"
<END>
<LOOP>
7: end loop
