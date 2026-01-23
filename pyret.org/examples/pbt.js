const example = `use context starter2024

import lists as L

nums = L.range(-10, 10)

l1 = L.filter(lam(n): n > 0 end, nums)
l2 = L.map(lam(n): n * n end, nums)

fun all-non-neg(l):
  cases (L.List) l:
    | empty => true
    | link(f, r) => (f >= 0) and all-non-neg(r)
  end
end

check "confirm none are negative":
  l1 satisfies all-non-neg
  l2 satisfies all-non-neg
end
`;

export const pbt = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [],
    editorContents: example,
    replContents: ""
}
