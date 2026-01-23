const example = `use context starter2024

people = table: name, age
  row: "Alicia", 30
  row: "Meihui", 40
  row: "Jamal", 25
end

check "filtering rows":
  sieve people using age:
    age > 35
  end
    is # find everyone older than 35; produces a new table
  table: name, age
    row: "Meihui", 40
  end
end

check "extracting a column":
  extract name from people end
    is # get all the names, in order; produces a list
  [list: "Alicia", "Meihui", "Jamal"]
end

check "order of columns matters":
  people 
    is-not # because the order of columns is different
  table: age, name
    row: 30, "Alicia"
    row: 40, "Meihui"
    row: 25, "Jamal"
  end
end
`;

export const tables = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [ "people" ],
    editorContents: example,
    replContents: []
}
