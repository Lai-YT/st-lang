var s := "*" % implicitly declaring s to be of type string
loop
    put s
    % by default, the maximum length of a string is 255 characters
    exit when length(s) = 10
    s := s + "*"
end loop
