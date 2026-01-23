
include csv

sheet = csv-table-file("./animals.csv", { header-row: true })
load-table: name, species, sex, age, fixed, legs, pounds, weeks
  source: sheet
end