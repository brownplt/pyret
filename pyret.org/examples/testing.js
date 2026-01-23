const example = `use context starter2024

import lists as L
import statistics as S

sqrt-2 = num-sqrt(2)

check "√2":
  sqrt-2 is-roughly 1.414213
  sqrt-2 is%(within(0.5)) 2
end

l1 = [L.list: 1, 2, 3, 8, 11]
l2 = [L.list: 1, 2, 3]

check "mean of a list of numbers":
  S.mean(l1) is 5
  # Let's tell apart mean from median
  S.mean is-not 3
  # Let's check for an error
  S.mean([L.list: ]) raises "is empty"
  # Let's explain the answer
  S.mean(l2) is 2 because (1 + 2 + 3) / 3
end
`;

export const testing = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [],
    editorContents: example,
    replContents: ""
}
