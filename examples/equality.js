const example = `use context starter2024

data Box: box(v) end

data MutBox: mbox(ref v) end

b1 = box(3)
b2 = box(3)
mb1 = mbox(3)
mb2 = mbox(3)

check "equal-always":
  equal-always(b1, b2) is true
  equal-always(mb1, mb2) is false
  (b1 == b2) is true
  (mb1 == mb2) is false
end

check "equal-now":
  equal-now(b1, b2) is true
  equal-now(mb1, mb2) is true
  (b1 =~ b2) is true
  (mb1 =~ mb2) is true
end

check "identical":
  identical(b1, b2) is false
  identical(mb1, mb2) is false
  (b1 <=> b2) is false
  (mb1 <=> mb2) is false
end
`;

export const equality = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
