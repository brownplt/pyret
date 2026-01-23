#lang pollen

◊(define-meta title "")
◊(define-meta rel-path "..")

◊div[#:class "container"]{
  ◊div[#:class "row d-flex justify-content-center"]{
      ◊div[#:class "col-md-8"]{

◊h1{Primitive types}

◊p{TL;DR: Pyret has them, and not everything acts like an object anymore.}

◊p{In Pyret 2013, numbers, strings, and booleans had fields.  These were all
methods that performed the builtin primitive operations, like addition,
computing the length of a string, etc.}

◊p{This is no longer true.  Numbers, strings, and booleans no longer have fields,
and no longer have object-like behavior.  The methods that were present on them
have been added to the default namespace, in most cases prefixed with num- or
string-.  For example, in 2013, you would have written:}

```
check:
  5.modulo(2) is 1
end
```

◊p{And now you write:}

```
check:
  num-modulo(5, 2) is 1
end
```

◊p{There are a number of reasons for this that we could go on at length about
(and probably will in a blog post at some point), but in brief:}

◊ul{
    ◊li{The long-term space and time performance implications for both typed and
  untyped code are significant}
    ◊li{We were orginally enamored with the idea that any object could enjoy the
  number or string interface and be indistinguishable from a primitive number
  or string.  Turns out that in a real language that just ain't gonna happen:
  the difference between your object that's pretending to be a string and a
  real string is going to get noticed when it's passed to libraries that talk
  to the Real World and need to, say, print real bytes into a file.  So we
  might as well be honest with the language's values and include them for
  programmers to use.}
}

◊h1{fun -> lam}

◊p{We changed the keyword for anonymous functions from fun to lam.  The typo of}

```
fun(x, y):
  body
end
```

◊p{is really hard to detect (for humans), and hard to explain even if you have a
computer detect it.  Keeping they keywords separate will hopefully let us give
better parse error messages in the future, and less ambiguous descriptions of
syntax right now.}

◊h1{Constructor syntax, and no more list literals}

◊p{Pyret 2013 supported list literals, like:}

```
[1, 2, 3]
```

◊p{We're not convinced that lists deserve such special treatment, so we have
generalized the syntax for creating collections to require the collection type
at the front.  So lists are created with:}

```
[list: 1, 2, 3]
```

◊p{This lets us add sets and arrays with the same syntax:}

```
[set: 1, 2, 3]
[array: 1, 2, 3]
```

◊p{And constructors in this style can be written by programmers --- the
constructors just need to follow a simple interface}

◊h1{Limited Annotation Checking}

◊p{Dynamic checking of assertions is an active research area without clear
solutions for some problems outside of theory.  We've struggled with
implementations of dynamic checks for higher-order annotations and record
annotations, and decided to (for now) simplify Pyret's enforcement of
annotations dynamically.}

◊p{Simple, flat types, like ◊code{Number} and ◊code{String}, will be enforced as before.
Record types will check that the listed fields are present, and will check
their annotations.  Refinements, written ◊code{T % (id)}, are still checked by
expecting id to be a Pyret function, then checking the T annotation, then
checking that the Pyret function returns true for the value.}

◊p{Pyret checks all flat annotations, like Number, String, or { x :: Boolean },
and only does limited checking for some annotations:}

◊ul{
    ◊li{Arrow annotations, like ◊code{(Number, String -> String)} will ◊em{only} check that the
  value is a function, and not wrap the function to check its arguments}
    ◊li{Parameterized annotations, like ◊code{List<Number>}, will ◊em{only} check the
  annotation before the ◊code{<>}, the contents the ◊code{<>} will be ignored.}
    ◊li{Type variables, like the ◊code{a} in ◊code{lam <a> (x :: a) -> a: x end}, will be
  ignored}
}

◊p{We still write out the full annotation that we mean whenever possible.  We're
still building up a static type checker which ◊em{will} handle all of these
features, and the more annotations you write now, the easier it will be to
typecheck your program (and get the corresponding speed boost) later.}

◊h1{Other Minor Changes}

◊p{The first exception in a check block outside of a "raises" test causes it to
fail, as opposed to being caught by "is" and "satisfies" with the check block
continuing.  This means that these two programs behave the same now, and they
didn't before:}

```
check:
  x = f() # where f() raises an exception
  x is y
end
```

```
check:
  f() is y # exception caught by is, tests keep running
end
```

◊p{We haven't made a final decision on parts of the equality algorithm for Pyret,
but we've moved away from the explicit method call.  In Pyret in 2013, the expression}

```
e1 == e2
```

◊p{meant}

```
e1._equals(e2)
```

◊p{Which made it so ◊code{==} didn't mean much: it could be completely user-defined.
We've written a built-in equality algorithm and removed the _equals method.
Because of concerns about assertion checking and eq-ness, the details of that
algorithm may change in the future, but probably in ways that most users won't
notice.}

◊p{We removed colon lookup operator for now (e:x and e:[e]), because it caused
lots of ambiguity as we tried to add different syntactic forms to the
language.  It may come back with different syntax if there is a need for it.}

◊p{We removed, but will add back, mutable and cyclic fields, and the graph: form.
In order to get a release out, we lagged on a few straightforward but time
consuming features to implement and test, and they'll come back this summer.}

} } }