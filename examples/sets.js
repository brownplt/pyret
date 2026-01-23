const example = `use context starter2024

import sets as S

s1 = [S.set: 1, 2, 3]
s2 = [S.set: 3, 2, 1]
check "sets are not ordered":
  s1 is s2
end

# Try \`pick\`ing a few times…do you always get the same result?
check:
  for map(n from range(0, 10)):
    s1.pick().elt
  end
  is-not
  [list: 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
end
`;

export const sets = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
