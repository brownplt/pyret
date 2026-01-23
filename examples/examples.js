export const example = `use context starter2024

fun sq(n):
  n * n
where:
  sq(0) is 0
  sq(1) is 1
  sq(-1) is 1
  sq(-5) is 25
end

examples "cube function":
  cb(0) is 0
  cb(3) is 27
  cb(-5) is -125
end

fun cb(n):
  n * n * n
end
`;

export const examples = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [ ],
    editorContents: example,
    replContents: ""
}
