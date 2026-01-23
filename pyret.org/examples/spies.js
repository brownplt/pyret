const example = `use context starter2024

fun gcd(a, b):
  spy: a, b end
  if b == 0:
    a
  else:
    gcd(b, num-modulo(a, b))
  end
end

check:
  gcd(13, 17) is 1
end
`;

export const spies = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [ ],
    editorContents: example,
    replContents: ""
}
