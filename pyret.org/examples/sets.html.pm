#lang pollen

◊p{
   Though many libraries in Pyret use lists, Pyret also has built-in support for sets, which are more appropriate in some
   settings than lists. In Pyret, sets behave as one would truly want them to: there is no such thing as the “first” element (as with lists),
   and instead programs use ◊code{pick} to extract an element.
}

◊p{
   What happens if you ◊code{pick} multiple times? Pyret does not want programs to get dependent on a particular behavior—sets,
   after all, do not have an order, but if the implementation acted ◊emph{as if} they did, programs would grow to depend on that.
   Therefore,  a
   ◊link/new-tab["https://pyret.org/docs/latest/pick.html#%28part._.The_.Pick_.Datatype%29"]{◊code{Pick}}
   is ◊emph{like} a “first and rest”, except
   there's no guarantee which “first” element you will get; the “rest” corresponds to all the other elements
   depending on what was chosen “first”.
}
