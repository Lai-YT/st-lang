% all of the elements in an array is true
function all(arr: array 1..* of bool, size: int): bool
  for i: 1..size
    if not arr[i] then
      result false
    end if
  end for
  result true
end all

% none of the elements in an array is true
function none(arr: array 1..* of bool, size: int): bool
  for i: 1..size
    if arr[i] then
      result false
    end if
  end for
  result true
end none
