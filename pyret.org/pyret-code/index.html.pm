#lang pollen

◊(define-meta title "Why Pyret?")
◊(define-meta rel-path "..")

◊div[#:class "container"]{
  ◊div[#:class "row d-flex justify-content-center"]{
      ◊div[#:class "col-md-8"]{

◊h1{The Pyret Code; or ◊br[] A Rationale for the Pyret Programming Language}

We need better languages for introductory computing. A good
introductory language makes good compromises between expressiveness
and performance, and between simplicity and feature-richness. Pyret is
our evolving experiment in this space.

◊h3{Why not just use Java, Python, OCaml, or Haskell?}

◊p{
One of the enduring lessons from the Racket project is that ◊em{no
full-blown, general-purpose programming language} is particularly
appropriate for introductory education. By the time a language grows
to be useful for building large-scale systems, it tends to have
accumulated too many warts, odd corners, and complex features, all of
which trip up students. The ◊a[#:href "http://cs.brown.edu/~sk/Publications/Papers/Published/fffkf-drscheme-journal/"]{journal paper for DrScheme}
(the old name for DrRacket) explains this in some detail.
}

◊h3{How about Racket?}

◊p{
Indeed, our closest fellow travelers of are the
Racketeers. In fact, the first version of Pyret
was merely a ◊code{#lang} in Racket. Nevertheless, Pyret represents a
departure from Racket (for now and for the near future, at least) for
several reasons:
}

◊ul[#:class "custom-bullets"]{
  ◊li{
    We wanted to experiment with syntax. Much as many of us love
    parentheses, we fear that Racket will always bump into an acceptance
    threshold due to its syntax. We're delighted to see the growing
    adoption in industry of languages like Racket and Clojure, and maybe
    the days of paren-phobia are over. But academics are far more
    hidebound than industrial programmers!
  }
  ◊li{
    We wanted to build a really great run-time system for the Web
    browser. Going through Racket and
    ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/yk-whalesong-racket-browser/"]{Whalesong}
    proved to be a non-starter in terms of performance, and Racket has
    many features that make an efficient implementation on today's
    JavaScript very hard. Building a native JavaScript implementation
    was the only option we could see. Over time, as technology changes,
    this could change.
  }
  ◊li{
    Though our pedagogy is heavily inspired by
    ◊a[#:href "https://htdp.org/"]{◊em{How to Design Programs}},
    it also diverges in some ways, reflecting the somewhat
    different backgrounds and preferences of team. Pyret embodies ◊em{our}
    educational philosophy, as embodied in
    ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/kf-data-centric/"]{this article}
    and in the book
    ◊a[#:href "https://dcic-world.org/"]{◊em{A Data-Centric Introduction to Computing}}.
    We felt that we could more easily experiment if
    we had a clean-slate design than if we had to keep fitting our work
    into the constraints of Racket.
  }
  ◊li{
    Ultimately, Racket's ◊code{#lang} facilities, though designed to create
    new languages—and a great prototyping ground for Pyret—proved to not
    be quite enough to support a language creation process of the scale
    of Pyret; and the need for a strong Web run-time system also meant
    that we did not get enough out of the Racket ecosystem (see instead
    ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/bnpkg-stopify/"]{where we ended up}).
    Nevertheless, that only represents the state of systems today; if
    someday the two grew closer together, many or all of us would
    rejoice.
  }
}

◊h3{Will Pyret ever be a full-fledged programming language?}

◊p{
Yes.
}

◊p{
First of all, Pyret is much more powerful than you might realize.
Pyret is already fully-fledged enough to self-host its compiler, which
is a non-trivial and realistic challenge. What that means is, when you
run Pyret in your browser, it loads JavaScript code that implements a
Pyret-to-JavaScript compiler (i.e., it compiles the Pyret you type
into JavaScript and runs it in the browser). This compiler was
produced by the Pyret-to-JavaScript compiler by compiling the
Pyret-to-JavaScript compiler. Take a look at the compiler's
◊a[#:href "https://github.com/brownplt/pyret-lang/"]{bootstrapping phases}
to get a sense of its sophistication.
}

◊p{
Second, underneath Pyret is a very powerful run-time system based on
over a decade of research. You don't see it as a user of the language,
and that's the point. Many other languages expose the
limitations of JavaScript's run-time to users (e.g., can't halt a
long-running computation, can't yield control to the event loop,
etc.). These languages effectively let ◊em{the medium become part of the
message}, whereas we believe programmers — especially early-stage
student programmers — should not have to confront these complexities,
which are irrelevant to (and often significantly interfere with) the
material they are trying to learn. Imagine if other languages said,
“We'd love to give you function calls, but your machine's instruction set
doesn't contain them, so we can't — sorry!” Yet they do the equivalent
when it comes to giving you control over your computation on top of
JavaScript. In contrast, Pyret is uncompromising.
}

◊p{
Third, if you want to teach a media-rich curriculum, you actually need
a pretty full-featured language at least under the hood. For instance,
Pyret's
◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/plpk-reactor-design/"]{built-in support for reactive programming}
requires a much more
sophisticated run-time system — and corresponding language features —
than one that didn't offer this at all or just punted to JavaScript
for this support. (Essentially, event-loops are first-class entities
in the language.) We just haven't emphasized these features when
talking about Pyret, focusing instead on the curricula they support.
}

◊p{
Broadly, we view ◊em{building an awesome teaching language} as a useful
design discipline that necessarily entails all the features typically
expected of a mature language.  When building a language, you're
constantly confronted with questions: what to do next, how to do it,
and whether to do it at all. Language designers therefore need a
mental framework that guides their choices. For some, it might be
“Build an awesome language for shared-memory concurrency!” For others
it might be “Build an awesome language for writing scientific
computations very, very concisely!”  For us, it's “Build an awesome
teaching language!” So whenever we're confronted with a design (or
implementation) choice, we first ask how it would play out ◊em{in this
specific context}. Then we ask how it would impact our long-term
goal. We have yet to find actual contradictions between the two, but
it's certainly re-ordered priorities.
}

◊h3{There are lots of kinds of “education”.}

◊p{
That's right. We are focused on introductory programming education at
the school and college levels, and Pyret is actively being ◊em{used} at
these levels. It is used in several  “CS 1” and
“CS 2” college-level courses. It is also a central part of
most of the curricula
of the ◊a[#:href "https://www.bootstrapworld.org/"]{Bootstrap project}
to teach algebra, data science, AI, physics, and more at the middle- and
high-school levels.
This gives us a very tight feedback loop.
}

◊p{
Of course, even in that setting there are differences of opinion about
what needs to be taught. Some believe inheritance is so important it
should be taught early in the first semester. We utterly reject this
belief (as someone once wisely said, “object-oriented programming does
not scale down”: what is the point of teaching classes and inheritance
when students have not yet done anything interesting enough to
encapsulate or inherit from?). Some have gone so far as to start
teaching with Turing Machines. Unsurprisingly, we reject this view as
well.
}

◊p{
What we do not take a dogmatic stance on is exactly how early state
and types should be introduced. Pyret has the usual stateful
operations. We discussed this at some length, but eventually decided
an introduction to programming ◊em{must} teach state.
Pyret also has optional annotations, so different instructors can,
depending on their preference, introduce types at different times.
}

◊h3{What are some ways the educational philosophy influences the language?}

◊p{
Pyret is driven by the ◊a[#:href "http://www.htdp.org/"]{◊em{How to Design Programs} (HtDP)} philosophy of programming education; one could almost view it as a language designed to make teaching from HtDP comfortable. However, we also have our own curricular ideas that extend or run parallel to those of HtDP, which we have published in a self-contained and comprehensive book, ◊a[#:href "https://dcic-world.org/"]{◊em{A Data-Centric Introduction to Programming} (DCIC)}.
}

◊p{
Some of our central ideas (many shared with HtDP) include:
}

◊ul[#:class "custom-bullets"]{
  ◊li{
    Languages should offer a rich set of values. For instance, images
    should be primitive values, fully supported by the environment. This
    improves the teaching of several things, from image-based
    composition exercises (which are often far more interesting than
    composition over numbers) to animations and games.
  }
  ◊li{
    Languages should offer syntactic support for as much as possible of
    the HtDP design recipe. (Pyret does not offer explicit support for
    templates, but then again we're rethinking the pedagogy of the
    template step.)
  }
  ◊li{
    Design recipe support includes good data definition primitives, including
    the expression of invariants. Therefore, Pyret has support for refinements
    (which are currently checked dynamically; a future version may add static
    support, but this is not our highest priority). In particular, by allowing
    algebraic datatypes to also be objects, Pyret offers significant flexibility
    and expressiveness.
  }
  ◊li{
    Students should be able to easily write examples as a precursor to
    writing code. In this regard, Pyret borrows but (we believe) syntactically
    improves upon Racket's ◊code{check-expect} family of operations with ◊a[#:href "https://www.pyret.org/docs/latest/testing.html"]{examples and testing}.
  }
  ◊li{
    Students should easily be able to escalate from simple examples to
    sophisticated testing, such as writing test oracles.
  }
  ◊li{
    DCIC views tables as a central and underappreciated datatype, and
    a more useful “first compound data structure” than, say, the lists
    commonly used in functional programming. We discuss this in more
    detail ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/kf-data-centric/"]{in our position paper}.
    Pyret therefore offers native support for tables, and allows
    spreadsheets to easily be imported as tables (thereby making
    spreadsheets our “database”).
  }
  ◊li{
    Equality is subtle and languages should respect its nuances.
    Students must understand the meaning of equality and its
    consequences, especially with regard to observations in the presence
    of state. Therefore, Pyret has carefully developed
    ◊a[#:href "https://www.pyret.org/docs/latest/equality.html"]{equality primitives}.
  }
  ◊li{
    Reactivity is both interesting and important. Pyret has an
    ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/plpk-reactor-design/"]{elegant model}
    for describing animations and other reactive computations that is
    both powerful and coherent with the rest of our pedagogy.
  }
}

◊h3{Is Pyret also a research project?}

◊p{Yes and no.}

◊p{
Yes in that, broadly speaking, we view what we are doing as very much
a research effort. We have specific, novel goals in mind (some of
which we've described elsewhere in this document), and finding good
solutions to achieve
those goals will require innovation. This is the very essence of
research. Some of that research is on the curricular side, though, and
may not require any language innovation. Indeed, as much as possible
we want Pyret to remain a language that is easy to approach and
understand.
}

◊p{
However, “research” also has a narrow meaning in academia, in the
sense of publishing lots of papers. This is an un-goal, and almost an
anti-goal. Every paper takes months to write, and those are months we
are not spending on the language and curriculum. We view this as a
poor time trade-off. We'll write papers sometime, but our immediate focus is
on shipping code and textbooks and other materials of immediate value
to students and educators. If this means we get “scooped” on some of
our technical innovations, that's just fine; we consider that a good
trade-off.
}

◊p{
Ultimately, though, research ◊em{requires} doing new things. We don't
want to do new things just for the sake of it. We've long been
inspired by this quote from
◊a[#:href "https://www.paulgraham.com/desres.html"]{Paul Graham}:
}

◊blockquote{
    The difference between design and research seems to be a question of
    new versus good. Design doesn't have to be new, but it has to be
    good. Research doesn't have to be good, but it has to be new.
}

◊p{
For us, design is essential; research is optional. We actively dogfood
Pyret both as teachers (actively teaching with it) and as
programmers (actively building things with it), which gives us
ongoing feedback about its points of friction. Where necessary we have
done and will continue to do research, but publishing academic papers
about it — rather than putting it to work educationally — will
continue to take a back seat.
}

◊h3{What are some works in progress?}

◊p{
Pyret has some support for static typing. We chose a conventional type
system with tagged unions and a type ◊em{checker}, resulting in
straightforward type errors without the complications associated
with type ◊em{inference} algorithms. However, there are still some rough
edges to the type system. In particular, typing ◊em{tables} is
◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/lgk-b2t2/"]{very hard}
and remains an open problem.
}

◊p{
If you'd like to stay abreast of our developments or get involved in
our discussions, please
◊a[#:href "http://www.pyret.org/discuss/"]{come on board}!
}

◊h3{Why is your filename suffix `.arr`?}

◊p{
Because ◊a[#:href "http://dialectblog.com/2011/05/24/pirate-accent/"]{pirates supposedly said} “arrr!” (or “yarrr!”) a lot. (Sometimes they ◊a[#:href "http://www.arrr.net/"]{sing}, too.) Note that you must pronounce it with a guttural sound, so it can't be mistaken for a file written in the R programming language. You should consider swashing your buckler as you speak.
}

◊h3{Does the skull in your logo have a name?}

◊p{
Yes, she's ◊a[#:href "https://en.wikipedia.org/wiki/Anne_Bonny"]{Bonny}!
}

◊h3{Where is the ◊a[#:href "https://www.facebook.com/shriram.krishnamurthi/posts/10157066386395581?comment_id=10157070487615581&notif_t=comment_mention&notif_id=1466124885214745"]{proximal end of the second femur}?}

◊p{Look closer. It's a lambda.}
      }}}
