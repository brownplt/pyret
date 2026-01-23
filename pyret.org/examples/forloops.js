const example = `use context starter2024

for each(n from range(0, 10)):
  print(n)
end
# prints 0, …, 9

check "map":
  for map(n from range(0, 5)):
    n * n
  end
    is [list: 0, 1, 4, 9, 16]
end

check "filter":
  for filter(n from range(0, 10)):
    n >= 5
  end
  is
  [list: 5, 6, 7, 8, 9]
end

check "fold":
  for fold(sum from 0, n from range(1, 11)):
    sum + n
  end
    is 55
end
`;

export const forloops = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
