#lang pollen

◊p{
   Unlike in many other languages, you may have noticed that ◊code{[…]} is
   not reserved for lists; instead, programs need to write ◊code{[list: …]}
   to construct a list. This is because Pyret does not want to over-privilege
   a single datatype; different programs depend on different collections of them,
   and it is nice to be able to define them comfortably.
  }

◊p{
   Thus, in Pyret, several datatypes have convenient constructors besides lists:
   sets and dictionaries are good examples. But programs can also define
   their own constructors! The process is a bit unwieldy so that custom
   constructors also have good performance. But this unwieldy code only needs
   to be written once, by the constructor creator; users of the constructor
   do not see this.
   }
