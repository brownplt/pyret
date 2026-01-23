#lang pollen

◊p{As programs get more sophisticated, it is often not enough to write
   unit tests; we need to test properties. Pyret gives you
   ◊link/new-tab["https://pyret.org/docs/latest/testing.html#%28part._.Unary_.Test_.Operators%29"]{primitives}
  for expressing the idea of values satisfying predicates.}

◊p{Pyret does not, however, provide data generators for property-based
  testing, because writing those is usually instructive and also a
  good way to learn about and explore biases in data.}
