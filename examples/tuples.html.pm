#lang pollen

◊p{
   Pyret has support for tuples, which are collections of ordered data of fixed size. Elements of tuples are accessed by position.
   Tuples can also be destructured at variable binding.
}

◊p{
   However, we caution against using tuples too much. We feel that tuples are best used either within a function itself, or when a
   called function needs to return multiple distinct values that will immediately be destructured and named. If a tuple
   flows intact through a program, after a while it becomes very difficult to tell what it represents, and it may even be
   confused with other tuples that have at least as many elements.
   In the latter cases, it's better to use an object with named fields, or (if the datum is sufficiently significant and
   visible in many parts of the program) a fresh datatype.
}
