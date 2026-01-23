#lang pollen

◊(define-meta title "")
◊(define-meta rel-path "..")

◊div[#:class "container"]{
  ◊div[#:class "row d-flex justify-content-center"]{
      ◊div[#:class "col-md-8"]{

◊h2{Pyret Summer Updates 2021}

◊p{We've been working on a few improvements and new features in Pyret that you'll
surely notice!}

◊ul{
    ◊li{A UI refresh}
    ◊li{Reduced Google Drive permissions}
    ◊li{All of the ◊code{image} library functions available in new programs by default}
    ◊li{A new language feature -- a way to control the names in programs based on the
modules work deployed last year}
}

◊p{There should be no backwards incompatibilities in this release, which is kind of
the point (see below about how we define and accomplish that).}

◊h2{UI Refresh}

◊p{The most immediate thing you'll notice when visiting
◊a[#:href "https://www.pyret.org"]{code.pyret.org} is the UI work of ◊a[#:href "https://www.adamsolove.com/"]{Adam
Solove}. We think the page is cleaner and easier to
navigate, and a number of menus and dialogs have either had bugs fixed or gotten
more readable layouts. This means a more consistent, thoughtful design across
the whole interface.}

◊p{<img src="/img/cpo-ui.png" alt="Code Pyret UI"/>}

◊p{These are just a few places where the consistent, clutter-free and familiar
style has been applied.}

◊p{<img width="100%" src="/img/save-a-copy.png"/>}

◊h2{Updated, Reduced Google Drive Permissions}

◊p{Pyret used to have a permissions screen that asked for access to users' entire
Google Drive and all images and spreadsheets. These broad permissions were
needed to make the "Insert Image" button work on a wide variety of default
browser settings, to allow users to import spreadsheets of data that they owned
but were not public, and to allow code.pyret.org to find Pyret files in Drive
that weren't created in code.pyret.org.}

◊p{We've long heard from teachers and students that they'd prefer giving as little
access to code.pyret.org as possible (and we agree with them). As time has gone
on, we've realized these use cases and settings are rare and concentrated in
experienced users, and we've found technical solutions to enable all of the
common use cases without broad permissions. We've happily reached a point where
there is little reason to ask all incoming users for these broad permissions
when a smaller set will do.}

◊p{To that end, we've reduced the set of default permissions that code.pyret.org
asks for to just "Connect itself to your Google Drive" and "See, edit, create,
and delete only the specific Google Drive files you use with this app."}

◊p{<img src="/img/permissions-change.png" alt="Permissions change"/>}

◊p{For users who need the more advanced uses, under the Pyret menu there's a new
option to "Enable Full Google Access" which connects to Google Drive with the
larger set of permissions. You may want to use the larger permission set if:}

◊ul{
    ◊li{You rely on a workflow that involves putting Pyret files into your Google Drive
in some way ◊em{other} than creating them yourself through code.pyret.org (for
example, students share files with you and you'd like to see those files on your
code.pyret.org homepage, or you collaborate on a non-public library file with
others and want to import it with ◊code{my-gdrive})}
    ◊li{You want to work with private spreadsheets saved in your drive that haven't
been made public}
    ◊li{You have certain security options enabled in your browser and want to insert
images from your Drive – in particular if you have "3rd party cookies" disabled,
the "Insert" button for images cannot work without broader permissions.}
}

◊h2{Images Available without ◊code{include} in New Programs}

◊p{Many curricula that use Pyret have early exercises involving images. This means
that an early step many students need to perform is writing ◊code{include image} at
the top of their program. This can be an onerous extra step.}

◊p{When you start a blank program in code.pyret.org now, you'll see a line that
says ◊code{use context essentials2021}. This makes it so that the ◊code{image} library is
◊code{include}d by default into that program (this has some other positive
consequences, detailed below). In addition, all of ◊code{lists} is included, which
had some previous inconsistencies in which functions were provided by the module
versus the default environment.}

◊p{We can do this in a backwards-compatible way because of a new feature, ◊code{use
context}.}

◊h2{A New Feature – Contexts}

◊p{Programming languages aren't useful without some functionality provided "out of
the box." To that end, most languages have ◊em{some} names of built-in functions
and values defined for the programmer without the programmer having to type any
extra ◊code{import} or ◊code{include} statements; Pyret is no different. We call this set
of names the ◊em{default environment} or the ◊em{default context}.}

◊p{Pyret has had roughly the same default environment for a long time, with only a
handful of names added. Because Pyret is particular about
◊a[#:href "https://www.pyret.org/docs/latest/Bindings.html#%28part._.Shadowing%29"]{shadowing},
we risk breaking folks' code each time we add a new name!}

◊p{We designed a combined language feature and user interface solution to get
around this (that hopefully reflects some lessons from other languages, like
Racket's ◊code{#lang} line). The new feature is that programs can write, as the first
line:}

```
use context <some-module>
```

◊p{where ◊code{<some-module>} is anything that could be used with ◊code{import} or ◊code{include}.
The key difference between ◊code{use context} and ◊code{include} is that ◊em{only} the names
from that module are included, rather than being added to the default context.}

◊p{From now on, new programs created in code.pyret.org will use the context we've
designed to be up to date and useful for the current academic year. It still
won't change much, but it will reflect additions to the standard library and new
libraries used by broadly-used curricula. Crucially, for backwards compatibility:}

◊ul{
    ◊li{The ◊code{use context} line is saved as part of the file. This means that if you
have a program you saved in 2021, and you reopen it in or import it in 2023, it
will still have the ◊code{use context essentials2021} line it originally had, which
will have all the right names from that time.}
    ◊li{Programs ◊em{without} a ◊code{use context} line will act just as they did before. (In
fact, they will be using a context called ◊code{essentials2020} behind the scenes
which has exactly the context code.pyret.org had before this update).}
}

◊p{Finally, ◊code{use context} doesn't just work with our built-in modules, it works
with any module you've made. So you can publish a file and have students use it
as a context to design your own environment for them. More documentation and
examples are in the ◊a[#:href "https://www.pyret.org/docs/horizon/use.html"]{use
documentation}.}

◊h2{Credits}

◊p{This release includes contributions from ◊a[#:href "https://www.adamsolove.com/"]{Adam
Solove}, Raj Paul, Thomas Castleman, Joe Gibbs
Politz, and Benjamin S. Lerner.}

} } }