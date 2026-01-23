const example = `use context starter2024

fun sq(n :: Number) -> Number:
  n * n
end

check "annotations on sq":
  sq(2) is 4
  sq("hello") raises ""
end

fun sum(l :: List<Number>) -> Number:
  fold({(a, b): a + b}, 0, l)
end

check "annotations on sum":
  sum([list: 1, 2, 3]) is 6
  sum([list: "hello", "world"]) raises ""
end

fun s2cp(s :: String) -> String:
  # This is buggy: it should return a list of numbers
  string-to-code-points(s)
end

# Uncomment the next line to see the error highlight
# s2cp("Hello")
`;

export const annotations = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
