#lang pollen

◊(define-meta title "")
◊(define-meta rel-path "..")

◊div[#:class "container"]{
  ◊div[#:class "row d-flex justify-content-center"]{
      ◊div[#:class "col-md-8"]{

◊h2{Pyret Summer Updates 2020}

◊p{We've been working on a few improvements and new features in Pyret that we're excited to share.}

◊ul{
    ◊li{New image library functionality}
    ◊li{New syntax for controlling modules}
    ◊li{A new way to write more descriptive tests}
    ◊li{Basic accessibility infrastructure for screenreaders (not complete)}
    ◊li{Fixes for numerous small bugs}
}

◊p{There are some backwards incompatibilities in this release that we view as being ◊strong{minor} and unlikely to affect the vast majority of programs. We'll get those out of the way up front:}

◊ul{
    ◊li{◊code{because} is a new keyword that wasn't in Pyret's reserved keyword list. Programs that used ◊code{because} as a variable name will need to choose a new name for that variable.}
    ◊li{We have changed the way pinholes work for calculating centers of images, which affects how odd-sided polygons' centers behave.}
}

◊h2{New image library functionality}

◊p{Pyret's image library has been updated to include new image primitives (◊a[#:href "https://www.pyret.org/docs/latest/image.html#%28part._image_wedge%29"]{wedge} creates a slice of a pie, and ◊a[#:href "https://www.pyret.org/docs/latest/image.html#%28part._image_point-polygon%29"]{point-polygon} creates a polygon from a list of coordinates), new image combinators (such as ◊code{-list} variants of ◊code{above}, ◊code{beside} etc, which take a list of images instead of just two, and ◊a[#:href "https://www.pyret.org/docs/latest/image.html#%28part._image_overlay-onto-offset%29"]{overlay-onto-offset}, which is a generalization of ◊code{overlay-align} and ◊code{overlay-offset}), and new mechanisms for handling the ◊em{pinholes} of images.  Finally, we provide a ◊a[#:href "https://www.pyret.org/docs/latest/image.html"]{◊em{new, typed library}} for images, that uses Pyret data definitions (instead of strings) as the arguments to the image functions.}

◊h3{Pinholes}

◊p{Intuitively, think of overlaying images as pinning them together with a push-pin; the point where the pin connects the images is their pinhole.  By default, the pinhole is in the ◊em{visual center} of each image.  This has changed very slightly from before, where it used to be the ◊em{geometric} center of each image (measured by its bounding box); this only affects polygons with odd numbers of sides, and should simply make the images feel less "bottom-heavy" than before.  You'll now be able to align a triangle or pentagon at the center of a rectangle, or spin a star around its center, without it being lopsided.}

<table width="100%">
<tr><td><img src="https://paper-attachments.dropbox.com/s_4B59B1C3D2865C64DCB2ACAF8F520775A6DEABFA28947ADA3A106A539CCB2ABA_1576685296379_image.png"/><p>Pinhole at visual center of star</p></td>
<td><img src="https://paper-attachments.dropbox.com/s_4B59B1C3D2865C64DCB2ACAF8F520775A6DEABFA28947ADA3A106A539CCB2ABA_1576684829136_image.png"/><p>Star is visually centered inside circle</p></td></tr>

<tr><td><img src="https://paper-attachments.dropbox.com/s_4B59B1C3D2865C64DCB2ACAF8F520775A6DEABFA28947ADA3A106A539CCB2ABA_1576685308534_image.png"/><p>Pinhole at geometric center of star's bounding box</p></td>
<td><img src="https://paper-attachments.dropbox.com/s_4B59B1C3D2865C64DCB2ACAF8F520775A6DEABFA28947ADA3A106A539CCB2ABA_1576684864397_image.png"/><p>Star is below the visual center of circle</p></td></tr>
</table>

◊p{Additionally, we provide new functions ◊code{draw-pinhole} to see where the pinhole is in an image, ◊code{center-pinhole} to move it to its geometric center, and ◊code{move-pinhole} to move it by some specified offset.}

◊h2{Explaining test cases with ◊code{because}}

◊p{Often when writing tests, we have a choice: we can either write a test case that shows the expected answer, or we can write a test case that shows the expression that produces that answer:}

```
check:
  distance(0, 0, 3, 4) is 5
  distance(0, 0, 3, 4) is num-sqrt(num-sqr(3 - 0) + num-sqr(4 - 0))
end
```

◊p{The former is useful for sanity-checking results; the latter is useful in the design process for deducing how a function should be implemented.  Pyret now supports an optional ◊code{because} keyword on test cases to express both of these ideas at once:}

```
check:
  distance(0, 0, 3, 4) is 5 because num-sqrt(3 - 0) + num-sqr(4, 0))
end
```

◊p{Semantically, Pyret will first check whether the explanation (at the end, after ◊code{because}) matches the expected expression (after ◊code{is}), and warn the programmer that their expected answer and their explanation are inconsistent if they are not equal.  If they are, then Pyret continues to check the actual expression (at the beginning) against the expected expression as usual.}

◊p{A ◊a[#:href "https://www.pyret.org/docs/horizon/testing.html#%28part._.Reasons_for_tests__because_clauses%29"]{because clause} is Pyret's answer to the common teacher request to "show your work".  Once a few test cases are written that show work, additional tests can be written that don't need the extra clause.  Conversely, if a test case is unexpectedly failing, the programmer can write a ◊code{because} clause to elaborate on their reasoning.  Since Pyret will check that the explanation matches the expected result, this helps pinpoint errors in reasoning without having to debug the function implementation itself.}

◊h2{New Syntax (and Some Internal Improvements) for Modules}

◊p{We've added user-facing syntax for much more fine-grained control of names across module boundaries. Modules can now}

◊ul{
    ◊li{◊a[#:href "https://www.pyret.org/docs/latest/modules.html#%28part._.Re-exporting_values%29"]{Re-export values from other modules without naming them all}}
    ◊li{◊a[#:href "https://www.pyret.org/docs/latest/modules.html#%28part._s~3amodules~3aprovide-fewer%29"]{More easily rename and exclude names when providing}}
    ◊li{◊a[#:href "https://www.pyret.org/docs/latest/modules.html#%28part._.Data_definitions%29"]{More easily export names related to a particular data definition}}
}

◊p{This has also led to several improved error messages that relate source locations across modules or between definitions and interactions areas.}

◊h2{Basic Accessibility Infrastructure for Screenreaders}

◊p{If you load code.pyret.org with a screenreader enabled, you will now hear dictated results at interactions. For example, if you type (with a screenreader on) ◊code{2 + 2} and hit enter at interactions, you should hear "two plus two evaluated to four." Try it with images!}

◊p{Note that this is pre-alpha infrastructure that we're getting in place so we can make future improvements on top of it — there's more work to do for true screenreader support for navigation of code and values. Credit goes to Dorai Sitaram, Emmanuel Schanzer, and Sina Bahram for their work on this.}

◊h2{Credits}

◊p{This release includes contributions from
◊a[#:href "https://github.com/ayazhafiz"]{Ayaz Hafiz},
◊a[#:href "https://github.com/belph"]{Philip Blair},
◊a[#:href "https://github.com/BenMusch"]{Ben Muschol},
◊a[#:href "https://github.com/blerner"]{Ben Lerner},
◊a[#:href "https://github.com/ds26gte"]{Dorai Sitaram},
◊a[#:href "https://github.com/dwoos"]{Doug Woos},
◊a[#:href "https://github.com/InnPatron"]{Alexander Vo},
◊a[#:href "https://github.com/jpolitz"]{Joe Politz},
◊a[#:href "https://github.com/jswrenn"]{Jack Wrenn},
◊a[#:href "https://github.com/mkolosick"]{Matthew Kolosick},
◊a[#:href "https://github.com/schanzer"]{Emmanuel Schanzer},
◊a[#:href "https://sethpoulsen.github.io/"]{Seth Poulson},
◊a[#:href "https://github.com/shriram"]{Shriram Krishnamurthi},
◊a[#:href "https://github.com/sorawee"]{Sorawee Porncharoenwase},
◊a[#:href "https://github.com/tov"]{Jesse Tov}, and
◊a[#:href "https://github.com/ZacharyEspiritu"]{Zachary Espiritu}.}

} } }