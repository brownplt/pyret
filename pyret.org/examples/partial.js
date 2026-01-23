const example = `use context starter2024

fun double-numeric-string(s :: String) -> Number:
  cases (Option) string-to-number(s):
    | some(n) => n + n
    | none => raise('double-numeric-string: not a numeric string')
  end
end

check "normal operation":
  1 + double-numeric-string("2") is 5
end

check "checking for an exception":
  1 + double-numeric-string("hello") raises "not a numeric string"
end
`;

export const partial = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
