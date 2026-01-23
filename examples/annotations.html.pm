#lang pollen

◊p{
   Pyret allows you to optionally write annotations on any variable binding.
   These are checked dynamically.
   }

◊p{
   Dynamic checking can create a lot of run-time overhead (even changing a program's 
   big-O characteristics). Pyret uses a pleasant trade-off: it checks the
   outermost annotation only. This takes constant time and catches most errors,
   but lets a few subtler ones to be checked later.
   }

◊p{
   Pyret also ships with an ◊em{experimental} type checker, which covers most
   but not all of the language's features (tables are particularly tricky).
   You can access the type-checker by clicking on the Run button's drop-down
   to select the type-checker. Observe how the default program, even with the
   call to ◊code{s2cp} commented out, results in an error!
   }

◊p{
   ◊em{Note: after trying out the type-checker, ◊strong{please revert to the regular Run button}.
       Otherwise, you may get odd errors in some of the other feature tabs, which were
       intentionally not designed to pass the type-checker.}
   }
