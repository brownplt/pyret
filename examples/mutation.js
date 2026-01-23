const example = `use context starter2024

x = 3
# Uncommenting the line below will produce an error: try it out!
# x := 4

var y = 3
# Uncommenting the line below will produce an error: try it out!
# y = 4

var z = 3
# Mutation has an explicit syntax to avoid accidents
z := 4

fun make-counter():
  var ctr = 0
  # Use \`block\` for a sequence of instructions; 
  # remove it and see what happens!
  lam() block:
    ctr := ctr + 1
    ctr
  end
end

check:
  c1 = make-counter()
  c1() is 1
  c1() is 2
  c2 = make-counter()
  c2() is 1
  c1() is 3
  c1() is 4
end

data Box:
    # Mutable fields must be indicated with \`ref\`;
    # remove it and see what happens!
  | box(ref v)
end

b1 = box(0)

# Mutable fields are represented in a visually distinct way
b1

# Field mutation has a different syntax from variable mutation,
# because the two are semantically different
b1!{v: 2}

# Go back to the earlier box (still showing \`0\`) and click on it!
`;

export const mutation = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
