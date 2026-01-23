const example = `use context starter2024

# Explicit keyword, looks like most of the rest of Pyret
a1 = lam(x): x + 1 end

# Parenthetical, useful for concise expressions passed as arguments
a2 = {(x): x + 1}

# Special syntax for procedures; syntactically fragile!
a3 = (_ + 1)

check "add one":
  a1(10) is 11
  a2(10) is 11
  a3(10) is 11
end

s1 = lam(x, y): x + y end
s2 = {(x, y): x + y}
s3 = _ + _

check "two-parameter addition":
  s1(5, 10) is 15
  s2(5, 10) is 15
  s3(5, 10) is 15
end
`;

export const lambdas = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
