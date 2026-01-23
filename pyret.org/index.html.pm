#lang pollen

◊(require racket/string racket/set)
◊(require racket/list)
◊(require pollen/tag)

◊(define-meta title "Pyret")
◊(define-meta rel-path ".")

◊(define examples '(
		    ("images" . "Images")
		    ("rational" . "Rationals")
		    ("examples" . "Examples")
		    ("tables" . "Tables")
		    ("data" . "Data Structures")
		    ("annotations" . "Type Annotations")
		    ("testing" . "Testing")
		    ("reactors" . "Reactors")
		    ("spies" . "Spies")
		    ("lambdas" . "Lambdas")
		    ("forloops" . "Loops")
		    ("sets" . "Sets")
		    ("constructors" . "Constructors")
		    ("tuples" . "Tuples")
		    ("mutation" . "Mutation and State")
		    ("contexts" . "Contexts")
		    ("equality" . "Equality")
		    ("modules" . "Modules")
		    ("partial" . "Partial Functions")
		    ("ext_data" . "External Data")
		    ("pbt" . "Property-Based Testing")
		    ("oop" . "Object-Oriented Programming")
		   ))

◊(define all-examples (map car examples))
◊(define default-example "images")

◊(define-tag-function (example-pane attrs elems)
    (let ()
        (define id (cadr (assoc 'id attrs)))
        (define name (cadr (assoc 'name attrs)))
        (define active (assoc 'active attrs))
        (define active-show (if active " show active" ""))
        ◊div[#:class (string-append "tab-pane" active-show) #:id id #:example-name name #:role "tabpanel" #:aria-labelled-by (string-append name "-tab")]{
                       ◊p[#:class "example-info"]{
                            ◊(first elems)}}))

◊(define-tag-function (pyret-snippet attrs elems)
    ◊pre[#:class "pyret-example"]{ ◊(apply @ elems) })

◊(define (example-code example-name)
    ◊(let ()
        (define unique (gensym example-name))
        (define id (format "pyret-example-~a" unique))
    
        ◊div[#:class "runnable-pyret"]{
            ◊pre[#:class "pyret-example" #:id id]{}
            ◊script[#:type "module"]{
                import { example } from "./examples/◊|example-name|.js";
                const preElt = document.getElementById("◊|id|");
                preElt.innerText = example;
            }
        })
)

◊(define (open-example example-name)
    ◊(let ()
        (define unique (gensym example-name))
        (define button-id (format "pyret-example-~a-run" unique))
    ◊@{
        ◊button[#:class "runnable-pyret" #:id button-id]{Run it!}
        ◊script[#:type "module"]{
            import { makeEmbed } from "./node_modules/pyret-embed/dist/pyret.js";
            import { ◊example-name } from "./examples/◊|example-name|.js";

            if(!window.singleEmbed) {
                const startFrameContainer = document.getElementById("single-examples-frame")   
                window.singleEmbed = makeEmbed('single-example-editor', startFrameContainer, "./node_modules/pyret-embed/dist/build/web/editor.embed.html#footerStyle=hide&warnOnExit=false");
            }
            const embed = await window.singleEmbed;
            const button = document.getElementById("◊|button-id|");
            const modalElt = document.getElementById('example-modal');
            const modal = bootstrap.Modal.getOrCreateInstance(modalElt);
            button.addEventListener("click", () => {
                embed.sendReset(◊example-name);
                modal.show();
            });
        }
    }
    )
)


◊(define-tag-function (center6 attrs elems)
    ◊div[#:class "row d-flex justify-content-center feature"]{
        ◊div[#:class "col-md-6"]{ ◊(apply @ elems) }})

◊(define (nav-pills id ids names)
    ◊@[
        ◊ul[#:class "nav nav-pills" #:id id #:role "tablist"]{
            ◊li[#:class "nav-item" #:role "presentation"]{
                ◊button[
                    #:class "nav-link active"
                    #:id (format "~a-tab" (first ids))
                    #:data-bs-toggle "pill"
                    #:data-bs-target (format "#~a" (first ids))
                    #:type "button"
                    #:role "tab"
                    #:aria-controls (first ids)
                    #:aria-selected "true"]{◊(first names)}
            }
            ◊(for/splice ((ex (rest ids)) (name (rest names)))
                (let ()
                    ◊li[#:class "nav-item" #:role "presentation"]{
                        ◊button[
                            #:class "nav-link"
                            #:id (format "~a-tab" ex)
                            #:data-bs-toggle "pill"
                            #:data-bs-target (format "#~a" ex)
                            #:type "button"
                            #:role "tab"
                            #:aria-controls ex
                            #:aria-selected "false"]{◊name}
                    })
            )
        }
    ])

◊(define (examples-tabs examples-ids examples examples-names)
    ◊@[
        ◊div[#:class "row d-flex justify-content-center examples-pills"]{
            ◊div[#:class "col-md-8 nav-border"]{
                ◊ul[#:class "nav nav-pills" #:id "examplesTabs" #:role "tablist"]{
                    ◊nav-pills["examplesTabs" examples-ids examples-names]
                }
            }
        }
        ◊div[#:class "row d-flex justify-content-center examples-tab-top"]{
            ◊div[#:class "col-md-8 tab-box"]{
                ◊div[#:class "tab-content" #:id "examplesTabsContent"]{
                    ◊example-pane[#:active #t #:id (first examples-ids) #:name (first examples)]{◊(example-doc (format "examples/~a.html.pm" (first examples)))}
                    ◊(for/splice ((ex (rest examples)) (id (rest examples-ids)))
                        ◊example-pane[
                            #:name ex
                            #:id id]{
                                ◊(example-doc (format "examples/~a.html.pm" ex))
                            })
                }
            }
        }
    ])

◊(define (inline-example-doc name)
    (example-doc (format "examples/~a.html.pm" name)))
◊(define (example-doc path)
    (apply @ (rest (get-doc path))))

◊(define autograders
    ◊li[#:class "mt-3"]{Education requires more than software and books; it
    also requires tools like autograders. We provide them!})

◊(define images-as-values
  ◊p{

      For beginners of all ages, pictures (or “images”) are some of
      the most compelling media. Pyret offers excellent support for
      working with images within the language itself. Try them out in the first
      example below (and explore others)! You can also jump to reading about CURRICULA or FOR DEVELOPERS.

      })

◊(define no-install

    ◊p{ ◊b{Pyret is designed from the ground up to run entirely in regular browsers with no installation at all},
    avoiding frustrating student-hours lost to installers and platform choice and IDE configuration
    and more. Indeed, Pyret is running right on this very page – check out the
    examples with the “Run It!” buttons!})

◊(define medium-message
  ◊p{Pyret is built atop an advanced technology
    stack
    [◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/bnpkg-stopify/"]{1},
    ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/yk-whalesong-racket-browser/"]{2}]
    that makes this a pleasant experience while avoiding the
    costs and burdens of maintaining servers. Our view is that
    the crippling limitations of a platform (like the browser)
    must not become an impediment to education; rather, we
    should bend the platform to our needs. That is, the medium
    should not become the message.})

◊div[#:class "jumbotron"]{
    ◊div[#:class "container"]{
        ◊div[#:class "row d-flex justify-content-center"]{
            ◊div[#:class "col-md-6"]{
                ◊img[#:src "img/pyret-banner.png" #:class "title-logo"]{}
                ◊p{
Pyret is a programming language designed to serve as an outstanding
choice for programming education. It works effectively at many levels, with
several curricula in
active use incorporating Pyret. The language is under active
design and
development, and free to use or modify.
                }
                ◊p{
        ◊a[#:href "#getting-started" #:class "btn btn-primary btn-m hvr-border-fade"]{First Examples}
        ◊a[#:href "#curricula" #:class "btn btn-primary btn-m hvr-border-fade"]{Curricula & Books}
        ◊a[#:href "#devs" #:class "btn btn-primary btn-m hvr-border-fade"]{(Course) Developers}
        ◊a[#:href "javascript:void(0)" #:class "btn btn-primary btn-m hvr-border-fade show-all-examples"]{Major Features}
}
            }
            ◊div[#:class "col-md-6"]{
                ◊open-example["spin"]
                ◊pyret-snippet{
flag = image-url("https://.../pyret-sticker-caps.png")
blackout = rectangle(550, 425, "solid", "black")
blank-flag = place-image(blackout, 450, 285, flag)
bonnie = scale(0.75, image-url("https://.../pyret-logo.png"))
fun draw-bonnie(angle :: Number) -> Image:
  scale(0.5, place-image(rotate(angle, bonnie), 450, 285, blank-flag))
end
spinner = reactor:
  init: 0,
  on-tick: {(angle): angle + 5},
  to-draw: draw-bonnie
end
spinner.interact()
                }
            }
        }
    }
}

◊script[#:src "site/js/codemirror.js"]
◊script[#:src "site/js/runmode.js"]
◊script[#:src "site/js/pyret.js"]


◊div[#:class "container"]{
    ◊a[#:id "getting-started" #:class "anchor-target"]{}
    ◊h2{Programming In Pyret}

    ◊center6{◊no-install}

    ◊right-feature[
        ◊p{Programs that create images give immediate visual feedback. Functions
        that operate on images enable students to learn about function
        composition in an medium that is both engaging and educational.}
        ◊div{
            ◊open-example["images"]
            ◊pyret-snippet{
treetop = triangle(60, "solid", "darkgreen")
trunk = square(20, "solid", "brown")
tree = above(treetop, trunk)
            }
            ◊img[#:style "display: block; margin: auto;" #:src "img/tree.png"]
        }
    ]
    
    ◊left-feature[
        ◊div{
            ◊open-example["examples"]
            ◊pyret-snippet{
examples "cube function":
  cb(0) is 0
  cb(3) is 27
  cb(-5) is -125
end

fun cb(n):
  n * n * n
end
            }
        }
        ◊p{
            Pyret provides a pleasant syntax for writing illustrative examples
            of how functions should behave. These serve not only as
            documentation, but are also useful for students to demonstrate their
            understanding of a problem before they start programming. 
        }
    ]


    ◊right-feature[
        ◊p{
        Pyret's 
        ◊link/new-tab["https://pyret.org/docs/latest/numbers.html#(part._numbers)"]{number system}
        supports ◊em{exact rational} arithmetic for many operations.  This avoids having
        floating point as a curricular dependency early on. When approximations become
        inevitable, they have an explicit representation:
        ◊link/new-tab["https://pyret.org/docs/latest/numbers.html#%28part._numbers_.Roughnum%29"]{Roughnum}s.
        }
        ◊div[#:class "text-center"]{
            ◊open-example["rational"] 
            ◊img[#:src "img/rational.png" #:style "width: 30em;"]
        }
    ]

    ◊left-feature[
        ◊div{
            ◊open-example["forloops"]
            ◊pyret-snippet{
for each(n from range(0, 10)):
  print(n)
end
squares = for map(n from range(0, 5)):
  n * n
end
# for filter, fold, and more!
            }
        }
        ◊p{
            The ◊code{for} construct provides a familiar syntax for iterating
            over elements, and much more.
        }
    
    ]

    ◊right-feature[
        ◊div{
            ◊p{
                    Pyret provides modules, with a rich set of features to control
                    where they are found and where they are exported. Starter or
                    support code for assignments can be imported directly from
                    services like Github.
            }
            ◊img[#:src "img/tictactoe.png" #:style "margin: auto; display: block;"]
        }
        ◊div{
            ◊open-example["modules"]
            ◊pyret-snippet{
            import url("https://raw.githubusercontent.com/brownplt/pyret.org/...") as TTT

            X = TTT.X
            O = TTT.O
            Blank = TTT.Blank

            board-xox =
            TTT.board(
                [array:
                [array: X, Blank, Blank],
                [array: Blank, O, Blank],
                [array: Blank, Blank, X]])

            TTT.draw-board(board-xox)
            }
        }
    ]

    ◊center6{
    ◊p{◊b{And much much more!} Check out all the ◊a[#:href "javascript:void(0)" #:class "show-all-examples"]{major features} of Pyret!}
    }
    

    ◊div[#:id "example-modal" #:class "modal" #:tabindex "-1" #:role "dialog"]{
        ◊div[#:class "modal-dialog modal-fullscreen modal-centered" #:role "document"]{
            ◊div[#:class "modal-content"]{
                ◊button[#:type "button" #:class "btn-close" #:aria-label "Close"]{}
                ◊div[#:id "single-examples-frame" #:class "embed-container" #:style "width: 100%; height: 100%"]{}
            }
        }
    }

    ◊div[#:id "all-examples-modal" #:class "modal" #:tabindex "-1" #:role "dialog"]{
        ◊div[#:class "modal-dialog modal-fullscreen modal-centered" #:role "document"]{
            ◊div[#:class "modal-content"]{
                ◊button[#:type "button" #:class "btn-close" #:aria-label "Close"]{}
                ◊div[#:class "container-fluid"]{
                    ◊div[#:class "tab-pane"]{
                        ◊(let ()
                            ◊(define examples-shortnames (map car examples))
                            ◊(define examples-names (map cdr examples))
                            ◊examples-tabs[examples-shortnames examples-shortnames examples-names])
                    }
                    ◊div[#:id "examples-frame" #:class "embed-container" #:style "width: 100%; min-height: 20em; height: 100%"]{}

                }
            }
        }
    }
}
◊(define-tag-function (left-feature attrs elems)
    ◊@{
        ◊div[#:class "row d-flex justify-content-center feature"]{
            ◊div[#:class "col-md-6 d-flex align-self-center justify-content-center"]{ ◊(first elems) }
            ◊div[#:class "col-md-4 d-flex align-self-center justify-content-center"]{ ◊(second elems) }
        }
        ◊hr{}
    })

◊(define-tag-function (right-feature attrs elems)
    ◊@{
        ◊div[#:class "row d-flex justify-content-center align-middle feature"]{
            ◊div[#:class "col-md-4 d-flex align-self-center justify-content-center"]{ ◊(first elems) }
            ◊div[#:class "col-md-6 d-flex align-self-center justify-content-center"]{ ◊(second elems) }
        }
        ◊hr{}
    })


◊div[#:class "container"]{
    ◊a[#:name "curricula" #:class "anchor-target"]{}
    ◊h2{Curricula and Books}

    ◊left-feature[
        
        ◊p{For ◊b{grades 6-12 (secondary) students}, our partners at ◊a[#:href
        "https://www.bootstrapworld.org/"]{Bootstrap} are the leading designers
        of ◊em{integrated} computing curricula. All the Bootstrap curricula
        build primarily atop Pyret. Bootstrap covers numerous areas (with ties
        to algebra, data science, AI, physics, and more) and provides
        comprehensive materials that have been tested in thousands of classrooms
        and by tens of thousands of students every year. Bootstrap is also, by
        design, ◊em{modular}: you don't have to adopt a whole course, but can
        instead choose modules that fit best with what you're already teaching.
        Head over to Bootstrap to learn more!}

        ◊div{
            ◊div{
                ◊img[#:style "width: 10rem" #:src "img/algebra.png"]{}
                ◊img[#:style "width: 10rem" #:src "img/data-science.png"]{}
            }
            ◊div{
                ◊img[#:style "width: 10rem" #:src "img/physics.png"]{}
                ◊img[#:style "width: 10rem" #:src "img/reactive.png"]{}
            }
        }
    ]

  ◊right-feature[
    ◊img[#:style "width: 100%;" #:src "img/dcic.png"]

    ◊div{
        ◊p{Our book, ◊a[#:href "https://dcic-world.org/"]{◊em{Data-Centric Introduction to Computing}} (DCIC),
                provides a modern introduction to computing education. You can see some of the research
                [◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/fkt-teach-scope-mut/"]{1},
                ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/lkft-switch-fun-lang/"]{2},
                ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/lk-smol-tutor/"]{3}]
                that has driven its design and content.}

        ◊p{
        DCIC takes the position that introductory data ◊em{science} offers an interesting, accessible, and
        meaningful introduction to programming that addresses many problems that plague current
        introductory curricula. It then transitions from that to data ◊em{structures}.
        You can read our
        ◊a[#:href "https://cs.brown.edu/~sk/Publications/Papers/Published/kf-data-centric/"]{critique}
        that inspired the book.
        Pyret offers various features that support this introduction and transition.
        }

        ◊p{In particular, DCIC takes the position — driven by a
            significant body of literature in educational and
            cognitive science — that students learn programming better
            when they can compare and contrast related but different
            things. Thus DCIC teaches not one but two programming
            languages: Python in addition to Pyret. But the
            progression from Pyret to Python is (a) staged carefully
            to minimize difficulties, and (b) includes seeing them
            side-by-side. Pyret, in turn, is designed to facilitate
            this kind of comparison with Python}
    }
  ]

}


◊div[#:class "container"]{
    ◊a[#:name "devs" #:class "anchor-target"]{}
    ◊h2{For (Course) Developers}


    ◊right-feature[
        ◊p{Pyret has a ◊a[#:href
        "https://marketplace.visualstudio.com/items?itemName=PyretProgrammingLanguage.pyret-parley"]{Visual
        Studio Code extension} that opens files in the same visual editor as the
        examples above. It works anywhere Visual Studio Code can run, including
        on ◊a[#:href
        "https://docs.github.com/en/codespaces/the-githubdev-web-based-editor"]{github.dev}.
        Read more in ◊a[#:href "https://pyret.org/docs/horizon/platforms.html#%28part._.V.Scode_.Extension%29"]{the docs}.}
        ◊img[#:src "img/vscode.png" #:style "width: 100%"]
    ]
        

    ◊center6{
        ◊p{
            Pyret has ◊a[#:href "https://pyret.org/docs/horizon/modules.html#%28part._modules_url-file%29"]{specific libraries and features} for creating and deploying
            starter code for students seamlessly. We developed these features
            and workflows in our own courses, with our own TAs, and for our own
            curricula.
        }

    }

    ◊hr{}


    ◊right-feature[
        ◊p{
            All the examples on this page embed an instance of Pyret through its
            ◊a[#:href "https://www.npmjs.com/package/pyret-embed"]{embedding
            library}.
            You can embed Pyret on your own websites and projects by
            installing that ◊code{npm} package, which has an API for controlling and
            listening to the embedded instance.
        }
        ◊pre[#:style "display: inline-block"]{
const code =  `use context starter2024
dot = circle(50, 'solid', 'red')`;
pyretEmbed.sendReset({
    definitionsAtLastRun: code,
    interactionsSinceLastRun: ["dot"],
    editorContents: code,
    replContents: ""
});
        }
    ]


    ◊left-feature[
        ◊img[#:src "./img/cli.png" #:style "width: 30em;"]
        ◊p{
            Pyret runs from the command line via the ◊code{◊a[#:href
            "https://www.npmjs.com/package/pyret-npm"]{pyret-npm}} package.
            Nearly all libraries (including images) run the same offline and
            in-browser. This can be especially important for grading student
            code submissions in an automated way.
        }
    ]

}

◊script[#:type "module"]{
console.log("Welcome to the pyret.org console!");
console.log("It can be a bit noisy in here because the embedded instances log some information (which you might be interested in – have a look!)")
console.log("You may enjoy trying out some of the API affordances right from here.");
console.log("For example, when looking at the Major Features overlay, you can run `window.pyretEmbed.sendReset({ definitionsAtLastRun: '\"Hello, api!\"', interactionsSinceLastRun: [ ], editorContents: '\"Hello, api!\"', replContents: '' });`");
console.log("Noisy application logs below......");
console.log("-----------------------------------");
}

◊script[#:type "module"]{
    import { makeEmbed } from "./node_modules/pyret-embed/dist/pyret.js";
    ◊(for/splice ((ex all-examples))
        (format "import { ~a } from \"./examples/~a.js\";\n" ex ex))

    let initialized = false;
    async function createAllExamples() {
        if(initialized){ return; }
        initialized = true;
        const startFrameContainer = document.getElementById("examples-frame")   
        const embed = await makeEmbed('examples-editor', startFrameContainer, "./node_modules/pyret-embed/dist/build/web/editor.embed.html#footerStyle=hide&warnOnExit=false");
        window.pyretEmbed = embed;

        const tabs = { ◊(string-join all-examples ", ") }
        const tabElements = document.querySelectorAll(`#examplesTabs [data-bs-toggle="pill"]`);
        tabElements.forEach(tabElement => {
            tabElement.addEventListener('show.bs.tab', (event) => {
                const target = document.querySelector(tabElement.attributes["data-bs-target"].value);
                if(target.attributes["example-name"]) {
                    embed.sendReset(tabs[target.attributes["example-name"].value]);
                }
            });
        });
        embed.sendReset(tabs["◊|default-example|"]);
    }
    const showAll = document.getElementsByClassName("show-all-examples");
    const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById("all-examples-modal"));
    for(let i = 0; i < showAll.length; i += 1) {
        showAll[i].addEventListener("click", () => {
            modal.show();
            createAllExamples();
        });
    }
}

◊script[#:type "module"]{
    const preElts = document.getElementsByClassName("pyret-example");
    for(let i = 0; i < preElts.length; i += 1) {
        const preElt = preElts[i];
        const example = preElt.innerText.trim();
        CodeMirror.runMode(example, "pyret", preElt);
        preElt.classList.add("cm-s-default");
    }
}

◊script[#:type "module"]{
    // Close bootstrap modals when the close button is clicked
    const modals = document.getElementsByClassName("modal");
    for(let i = 0; i < modals.length; i += 1) {
        const modal = modals[i];
        const button = modal.getElementsByClassName("btn-close")[0];
        const bsModal = bootstrap.Modal.getOrCreateInstance(modal);
        button.addEventListener("click", () => {
            bsModal.hide();
        });
    }
}
