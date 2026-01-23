const example = `use context starter2024

include csv

animals-table =
load-table: name, species, sex, age, fixed, legs, pounds, weeks
    source: csv-table-url("https://raw.githubusercontent.com/brownplt/pyret-lang/refs/heads/horizon/tests/pyret/tests/csvs/animals-ds-2024.csv", { infer-content: true })
end

fun is-cat(row):
    row["species"] == "cat"
end

animals-table.filter(is-cat)

`;


export const ext_data = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [ ],
    editorContents: example,
    replContents: ""
}
