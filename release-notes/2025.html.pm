#lang pollen

◊(define-meta title "Pyret Updates 2025")
◊(define-meta rel-path "..")

◊div[#:class "container"]{
  ◊div[#:class "row d-flex justify-content-center"]{
      ◊div[#:class "col-md-8"]{

◊h2{Pyret Updates 2025}

◊p{We’ve released a few improvements and new features in Pyret that we are excited to share!}

◊ul{
    ◊li{A Visual Studio Code extension for running Pyret}
    ◊li{Improvements to offline Pyret via ◊a[#:href "https://www.npmjs.com/package/pyret-npm"]{pyret-npm} and the VScode extension}
    ◊li{New ways to import modules}
    ◊li{New ways to work with files, URLs, and images}
    ◊li{A new library for embedding Pyret in web pages}
    ◊li{Documentation and naming convention clean up}
    ◊li{Various bug fixes across libraries}
}

◊p{There should be no backwards incompatibilities in this release for existing
code.}

◊h2{VScode Extension}

◊p{Pyret now has a VScode extension:}

◊p{◊a[#:href "https://marketplace.visualstudio.com/items?itemName=PyretProgrammingLanguage.pyret-parley"]{Pyret Interactive Editor for VSCode}}

◊p{There are a few exciting things about this:}

◊ul{
    ◊li{If you're familiar with VScode for managing code, you can work with
    Pyret files within VScode with a full-featured visual editor with images,
    animations, interactions area, and so on, just like on code.pyret.org.}
    ◊li{The extension is a fully capable web extension, meaning it can run on
    ◊a[#:href
    "https://docs.github.com/en/codespaces/the-githubdev-web-based-editor"]{github.dev}.
    This means it provides another path to editing and running Pyret code
    (for free) without leaving the browser, with just a Github account.}
}

◊h2{Improvements to Offline Pyret}

◊p{The command-line version of Pyret, which most folks use through the ◊a[#:href
"https://www.npmjs.com/package/pyret-npm"]{npm package}, has seen a few
improvements:}

◊ul{
    ◊li{The ◊code{image} library is now fully functional from the command line.
    It uses the ◊a[#:href
    "https://www.npmjs.com/package/node-canvas"]{node-canvas} npm package to do
    this. From the command line—and from the VScode mode!—you can use
    ◊code{image-file} to read images from a local path, and ◊code{save-file} to
    save (and later view) images.}
    ◊li{We've added and documented a few new libraries including ◊a[#:href "https://pyret.org/docs/latest/csv.html"]{◊code{csv}},
    ◊a[#:href "https://pyret.org/docs/latest/filesystem.html"]{◊code{filesystem}}, and ◊a[#:href "https://pyret.org/docs/latest/fetch.html"]{◊code{fetch}} for getting more work done from the
    command line.}
}

◊h2{New Ways to Import Code and Data}

We've added the ability to import modules from URLs with ◊a[#:href
"https://pyret.org/docs/horizon/modules.html#%28part._modules_url%29"]{◊code{url(...)}}
and
◊a[#:href
"https://pyret.org/docs/horizon/modules.html#%28part._modules_url-file%29"]{◊code{url-file(...)}}
imports. This allows for development of
student-facing starter code and libraries for code.pyret.org without relying on
Google Drive.

We've also added functions to create tables from CSV data loaded ◊a[#:href
"https://pyret.org/docs/horizon/csv.html"]{from files or from URLs}; previously
this kind of data import really only worked well from Google Sheets. Now
arbitrary CSV files can be loaded into tables from the filesystem or the web
(or arbitrary text data with ◊a[#:href
"https://pyret.org/docs/latest/fetch.html"]{◊code{fetch}}).

◊h2{A New Embedding Library}

You can now embed the code.pyret.org editor directly into other web pages with
◊a[#:href "https://www.npmjs.com/package/pyret-embed"]{pyret-embed}. Indeed,
this is what is used to create the VScode extension!

The embedding library is suitable for showing interactive examples in online
tutorials, creating interactive lessons, presenting student code to TAs in a
web-based autograder, and more. We're curious what you build with it!

◊h2{Documentation Updates}

We've significantly updated and improved documentation of many core libraries.
In addition, we've used the embedding library to make most of the examples in
the docs ◊em{runnable}. For example, click the (Try it!) button in the ◊a[#:href
"https://pyret.org/docs/horizon/numbers.html#%28part._numbers_%2B._%28addition._operator%29%29"]{numbers
documentation}.

} } }
