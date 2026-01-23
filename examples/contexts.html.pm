#lang pollen

◊p{
   Modules are useful for providing new services (such as functions and types). However, sometimes users—especially educators—will
   want to ◊emph{limit} the set of visible services. For instance, certain functions may make a homework trivial, so they may
   want to ◊emph{remove} those functions from the set of visible services.
}

◊p{
   For this, Pyret provides ◊link/new-tab["https://pyret.org/docs/latest/use.html#%28part._s~3ause~3acontext%29"]{◊emph{contexts}}.
   A context definition is a description of the entire namespace. It starts with an empty
   namespace and adds to it until it has the desired contents, which it then exports.
   Thus a context determines not only what names are bound and not bound, but also what they are bound to.
}
