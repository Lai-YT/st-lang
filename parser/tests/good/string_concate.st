
const hello := "hello, "

begin
  const world := "world!"
  const helloWorld := hello + world
  put helloWorld
end

begin
  var name: string
  get name
  const helloName := hello + name + "!"
  put helloName
end
