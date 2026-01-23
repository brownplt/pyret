#lang pollen

◊p{
   Programmers often need to define partial functions. Rather than return “sentinel” values
   (which might fail only much later in the computation or, worse, be interpreted as valid
    response and never fail at all), Pyret offers two standard mechanisms.
   One is to raise an exception, while the other is use the ◊code{Option} type.
}

◊p{
   Exceptions make more sense when dealing with truly unexpected situations and/or
   ones from which there is no meaningful path to recovery.
   Options make more sense when the situation is reasonable to expect and/or is there
   some meaningful value that can be provided.
   Both can be used with testing.
 }
