const example = `use context starter2024

# In this particular context, this works:

check:
  [list: 1, 2, 3] is [list: 1, 2, 3]
end

# But in this context, this doesn't work:

check:
  [set: 1, 2, 3] raises ""
end

# What else might \`set\` be bound to?

# https://pyret.org/docs/latest/Glossary.html?q=set
`;

export const contexts = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
