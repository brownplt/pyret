const example = `use context starter2024

import lists as L
import sets as S
import string-dict as SD

l = [L.list: 1, 2, 3]
s = [S.set: 1, 2, 3]

check "sets are not lists":
  l is-not s
end

sd = [SD.string-dict: "alice", 1, "bob", 2]

check "string dictionaries at work":
  sd.get("alice") is some(1)
  sd.get("charlie") is none
end

# Let's define a new constructor, called \`sorted\`
# This takes numbers in any order, and puts them in sorted order

sorted = {
  make0: {(): empty},
  make1: {(n1): [list: n1]},
  make2: {(n1, n2): [list: n1, n2].sort()},
  make3: {(n1, n2, n3): [list: n1, n2, n3].sort()},
  make4: {(n1, n2, n3, n4): [list: n1, n2, n3, n4].sort()},
  make5: {(n1, n2, n3, n4, n5): [list: n1, n2, n3, n4, n5].sort()},
  make: {(args :: RawArray<Number>):
      raw-array-to-list(args).sort()}
}

check "\`sorted\` actually sorts":
  [sorted: ] is empty
  [sorted: 1] is [list: 1]
  [sorted: 2, 1] is [list: 1, 2]
  [sorted: 2, 1, 3] is [list: 1, 2, 3]
  [sorted: 4, 3, 2, 1] is [list: 1, 2, 3, 4]
  [sorted: 2, 1, 5, 3, 4] is [list: 1, 2, 3, 4, 5]
  [sorted: 2, 1, 6, 5, 3, 4] is [list: 1, 2, 3, 4, 5, 6]
  [sorted: 3, 1, 6, 7, 5, 2, 4] is [list: 1, 2, 3, 4, 5, 6, 7]
end
`;

export const constructors = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
