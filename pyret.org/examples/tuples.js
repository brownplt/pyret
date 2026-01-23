const example = `use context starter2024

# Tuple version

fun div-mod-tup(num, den) -> {Number; Number}:
  # Order matters, because we access by position
  { num-floor(num / den);
    num-modulo(num, den) }
where:
  div-mod-tup(5, 2) is {2; 1}
  div-mod-tup(10, 2) is {5; 0}
  div-mod-tup(17, 13) is {1; 4}
  # We can deconstruct on return (preferred: names are good!)
  {div; mod} = div-mod-tup(17, 13)
  mod is 4
  div is 1
  t = div-mod-tup(-5, 2)
  # We can also access by numeric position (use with care!)
  t.{0} is -3
  t.{1} is 1
end

# Object version

fun div-mod-obj(num, den) -> {div :: Number, mod :: Number}:
  # Order doesn't matter, due to names
  { div: num-floor(num / den),
    mod: num-modulo(num, den) }
where:
  div-mod-obj(5, 2) is {div: 2, mod: 1}
  # Order doesn't matter, due to names
  div-mod-obj(10, 2) is {mod: 0, div: 5}
  div-mod-obj(17, 13) is {div: 1, mod: 4}
  dmo = div-mod-obj(-5, 2) 
  dmo.div is -3
  dmo.mod is 1
end

# Datatype version

data DivMod: dm(div :: Number, mod :: Number) end

fun div-mod-dt(num, den) -> DivMod:
  # Order matters, because of the constructor
  dm(num-floor(num / den),
    num-modulo(num, den))
where:
  # Order matters, because of the constructor
  div-mod-dt(5, 2) is dm(2, 1)
  div-mod-dt(10, 2) is dm(5, 0)
  div-mod-dt(17, 13) is dm(1, 4)
  dmo = div-mod-dt(-5, 2) 
  dmo.div is -3
  dmo.mod is 1
end
`;

export const tuples = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
