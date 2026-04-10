#lang racket

(require txexpr)
(require pollen/core)
(require pollen/tag)

(require racket/date)

(require "pollenboots/utils.rkt")

(provide (all-defined-out))

(define (emph . elems)
  `(i () ,@elems))

(define (bold . elems)
  `(b () ,@elems))

(define (centered . elems)
  `(div ([align "center"]) ,@elems))

(define (code . elems)
  `(code ([class "uncolored-code"]) ,@elems))

(define (author . elems)
  `(div ([class "author"]) "by " ,@elems))

(define (get-date)
  (date->string (current-date)))

(define (include-section file)
  `(include-section-1 ([incfile ,file])))

; sections

(define (section-at-depth n title-elems #:tag [tag #f])
  (define title-sluggified (or tag (sluggify* title-elems)))
  (cond [(not (number? n))
         `(h5 ([id ,title-sluggified]) ,@title-elems)]
        [else
          (define level (number->string n))
          `(section-1 ([level ,level] [id ,title-sluggified]) ,@title-elems)]))

(define (section #:tag [tag #f] #:tag-prefix [tag-prefix #f] . titlex)
  (section-at-depth #:tag tag 2 titlex))
(define (subsection #:tag [tag #f] . titlex) (section-at-depth #:tag tag 3 titlex))
(define (subsubsection #:tag [tag #f] . titlex) (section-at-depth #:tag tag 4 titlex))

(define (subsubsub*section #:tag [tag #f] . titlex) (section-at-depth #:tag tag #f titlex))

(define (title #:tag [tag #f] #:version [version "0"]
               #:friendly-title [friendly-title #f]
               #:noimport [noimport #f]
               #:style [style #f]
               . title-terms)
  (define title-1
    (cond [friendly-title (list friendly-title)]
          [else title-terms]))
  (define title-sluggified
    (cond [tag tag]
          [friendly-title (sluggify friendly-title)]
          [else (sluggify* title-terms)]))
  `(title-1 ([level "1"] [id ,title-sluggified]) ,@title-1))

(define (docmodule name #:friendly-title [friendly-title #f] #:noimport [noimport #f] . body)
  `(div ()
        (module-tag-1 () ,name)
       ,(apply title #:tag name #:friendly-title (or friendly-title name) '())
       ,(if noimport `(span ())
            `(div ()
                  (p () "Usage:")
                  (pre ([class "pyret-highlight"]) "include " ,name)
                  (pre ([class "pyret-highlight"]) "import " ,name " as ...")))
       ,@body))

(define (itemlist . elems)
  `(ul () ,@elems))

(define (item . elems)
  `(li () ,@elems))

(define (nested #:style [style #f] . elems)
  (define attribs
    (if style `([class "insetpara nested"]) `([class "nested"])))
  `(div ,attribs ,@elems))

(define (para #:style [style #f]. elems)
  (define attribs
    (if style `([class ,style]) `()))
  `(p ,attribs ,@elems))

(define (hyperlink url . elems)
  `(a ((href ,url)) ,@elems))

(define link hyperlink)

(define (image #:scale [scale 1] file)
  `(img ([src ,file])))

(define pyret-method
  (case-lambda
    [(ig2 name)
     (ref-gloss (string-append "." name))]
    [(ig1 ig2 name mod)
     (ref-mod-gloss mod (string-append "." name))]
    [(ig1 ig2 name)
     (ref-gloss (string-append "." name))]))



(define (collection-doc name #:args [args #f] #:fields [fields '()] #:return [return ""] #:show-ellipses [show-ellipses #f])
  ; (printf "### collection-doc-3 ~s args= ~s fields= ~s return= ~s\n" name args fields return)
  (let ([x
          `(div ()
                ,(make-gloss name)
                (pre ([class "pyret-display"])
                "[" ,(ref-gloss name)
                ,(if args `(span () "(" ,@(add-between args ", ") ")") `(span ()))
                ": "
                ,@(add-between fields ", ")
                ", ...] -> "
                ,return))])
    ; (printf "### res = ~s\n" x)
    x))


(define (ignore . ign) "")

(define (doc-internal #:stack-unsafe [stack-unsafe #f] . elems)
  (if stack-unsafe
      `(div ()
            (span ([class "margin-note"])
                  "!→ means this function is not stack safe")
            (pre () ,@elems))
      `(div ()
            (pre ([class "pyret-display"]) ,@elems)
            )))

(define (margin-note* . elems)
  `(div ([class "margin-note"])
         ,@elems))

(define note margin-note*)

(define margin-note margin-note*)

(define (cpo-only . elems)
  `(div ([class "CPO"]) (div ([class "cpo-icon"]) ,@elems)))

(define (vscode-only . elems)
  `(div ([class "VSCode"]) (div ([class "vscode-icon"]) ,@elems)))

(define (cli-only . elems)
  `(div ([class "CLI"]) (div ([class "cli-icon"]) ,@elems)))

(define (vscode-cli-only . elems)
  `(div ([class "VSCodeCLI"]) (div ([class "vscode-cli-icon"]) ,@elems)))

(define (tabular #:sep [sep #f]
                 #:column-properties [column-properties #f]
                 #:row-properties [row-properties #f]
                 #:cell-properties [cell-properties #f]
                 #:style [style #f]
                 . rows)
  ; (printf "### doing tabular of ~s\n" rows)
  (define table-class "table table-sm")
  #;(for-each
    (lambda (row)
      (printf "### doing row...\n")
      (for-each
        (lambda (cell)
          (printf "### cell is ~s\n" cell))
        row))
    rows)
  `(table ([class ,table-class])
          (tbody ()
            ,@(for/list ([row (car rows)])
                `(tr ()
                     ,@(for/list ([cell row])
                         ; (printf "### cell is ~s\n" cell)
                         `(td () ,cell)))))))

(define (form a b . elems)
  ; (printf "doing form a = ~s\nb = ~s\nelems = ~s\n" a b elems)
  `(div ()
        ,(make-gloss a)
        (pre ([class "pyret-display"]) ,b)
        ,@elems))

(define (value #:style [style ""] name typ . elems)
  `(div ()
        ,(make-gloss name)
        (pre ([class "pyret-display"])
             ,name " :: " ,typ)
        ,@elems))

(define (type-spec #:alias [alias #f] #:private [private #f] type-name tyvars . body)
  ; (printf "### type-spec ~s ~s \n" type-name tyvars )
  (define og-type-name type-name)
  (cond [alias
          ; (printf "alias = ~s\n" alias)
          ; (set! type-name (string-append type-name " = " alias))
          ; (set! type-name (format "~a = ~a" type-name alias))
          `(div () ,(make-gloss og-type-name)
                (pre ([class "pyret-display"])
                     ,(ref-gloss og-type-name type-name))
                ,@body) ]
        [else
          (if (list? tyvars)
              (when (cons? tyvars)
                (set! type-name `(span () ,(ref-gloss og-type-name)
                                  "<"
                                  ,(apply string-append (add-between tyvars ", "))
                                  ">")))
              (set! body (cons  tyvars body)))
          `(div ()
                ,(make-gloss og-type-name)
                (pre ([class "pyret-display"]) ,type-name)
                ,@body)]))

(define (a-id name . args)
  (if (cons? args) (first args) name)) ;autoinclude tt?

(define (a-arrow . typs)
  ; (printf "### doing a-arrow of ~s\n" typs)
  (set! typs
    (filter (lambda (typ) (not (equal? typ "Brand"))) typs))
  (set! typs
    (map (lambda (typ) (if (null? typ) "()" typ)) typs))
  (when (= (length typs) 1)
    (set! typs (cons "()" typs)))
  (let ([res
          `(span () ,@(add-between typs ", " #:before-last " -> "))])
    ; (printf "### a-arrow produced ~s\n" res)
    res))

(define (p-a-arrow . typs)
  `(span () "(" ,(apply a-arrow typs) ")"))

(define (a-app base . typs)
  ; (printf "doing a-app base= ~s typs= ~s\n" base typs )
  (set! typs (map (lambda (typ)
                    (if (list? typ)
                        (if (and (> (length typ) 1) (memq (first typ) '(ref-gloss-1 span)))
                            typ
                            `(span () ,@(add-between typ ", ")))
                        typ)) typs))
  ; (printf "### typs is now ~s\n" typs)
  (set! typs `(span () ,@(add-between typs ", ")))
  (let ([x `(span () ,base "<" ,typs ">")])
    ; (printf "a-app ~s ~s ==> ~s\n" base typs x)
    x))

(define (a-ftype #:ml [ml #f] . typs)
  (let* ([arg-typs (drop-right typs 1)]
         [ret-typ (car (take-right typs 1))])
    (cond [ml
            `(span ()  "(\n  "
                   ,@(add-between arg-typs ",\n  ")
                   "\n)\n-> "
                   ,ret-typ)]
          [(null? arg-typs)
           `(span () " -> " ,ret-typ)]
          [else
            `(span () "(" (span () ,@(add-between arg-typs ", ")) ") -> "
                   ,ret-typ)])))

(define (p-a-ftype . typs)
  `(span () "(" ,(apply a-ftype typs) ")"))

(define (a-tuple . fields)
  `(span () "{" ,@(add-between fields ", ") "}"))

(define equal-always-op `(code "=="))
(define equal-now-op `(code "=~"))
(define identical-op `(code "<=>"))

(define (singleton-doc #:style [style ""] typename1 fieldname typename . elems)
  `(div ()
        ,(make-gloss fieldname)
        (pre ([class "pyret-display"]) ,(ref-gloss fieldname) " :: " ,typename)
        ,@elems))

(define (a-var-type val typ)
  `(span ([class "pyret-content"]) ,val " :: " ,typ))

(define (p-a-var-type val typ)
  `(span ([class "pyret-content"]) "(" ,val " :: " ,typ ")"))

(define (constructor-doc #:private [private #f] #:style [style #f] typename1 fieldname args typename . elems)
  ; (printf "constructor-doc typename1= ~s fieldname= ~s args= ~s typename= ~s elems= ~s\n" typename1 fieldname args typename elems)
  (let ([x
          `(div ()
                ,(make-gloss fieldname)
                (pre ([class "pyret-display"])
                     ,(ref-gloss fieldname) " :: ("
                     ,@(add-between
                         (map (lambda (arg)
                                `(span () ,(first arg) " :: " ,(second (third arg))))
                              args) ", ")
                     ") -> " ,typename)
                ,@elems
                (p) ;make-gloss seems to insert p on top, so match it with one on bottom
                )])
    ; (printf "x = ~s\n" x)
    x))

(define (method-doc #:alt-docstrings [alt-docstrings #f] #:contract [contract #f]
                    #:args [args "args"] #:return [return "return"]
                    data-name var-name name
                    . elems)
  ; (printf "### method-doc\n")
  (define methname (string-append "." name))
  (unless contract (set! contract "unspecified_contract"))
  `(div ()
        ,(make-gloss methname)
        (pre ([class "pyret-display"])
             ,methname " :: " ,contract)))

(define (repl-examples . elems)
  ; (printf "### repl-examples ~s\n" elems)
  `(div ()
        ,@(map (lambda (elem)
                 ; (printf "### elem = ~s\n" elem)
                 (define kar (car elem))
                 (set! kar
                   (map (lambda (x)
                          (if (and (string? x)
                                   (regexp-match-exact? #rx" +" x))
                              (string-append "   " x)
                              x))
                        kar))
                 ; (printf "### car elem = ~s\n" kar)
                 ; (printf "### cdr elem = ~s\n" (cdr elem))
                 `(div ()
                      (pre ([class "repl-example pyret-highlight"])
                           ,@kar)
                      ,@(cdr elem)))
               elems)))

(define (colorful-function-series)
  ; (printf "### colorful-function-series\n")
  `(pre () "colorful-function-series"))

(define (a-chart-window)
  ; (printf "### a-chart-window\n")
  `(pre () "a-chart-window"))

(define (a-record . fields)
  ; (printf "### a-record ~s\n" fields)
  (append  '(span ())
           (list "{")
           (add-between fields ", ")
           (list "}")))

  ; (string-append "{"
  ;   (apply string-append (add-between fields ", ")) "}")

(define (a-field name type . desc)
  ; (printf "### a-field ~s ~s ~s\n" name type desc)
  `(span () ,name " :: " ,type))

  ; (string-append name " :: " type)

(define (append-gen-docs . desc)
  "")

(define (section-number-css here-html)
  (define p (page-section-prefix here-html))
  (if (not p)
      ""
      (let ([pd (string-append p ".")])
        (string-append
          ".container { counter-reset: h2c 0; }\n"
          ".container h1::before { content: \"" p " \"; }\n"
          ".container h2 { counter-increment: h2c; counter-reset: h3c 0; }\n"
          ".container h2::before { content: \"" pd "\" counter(h2c) \" \"; }\n"
          ".container h3 { counter-increment: h3c; counter-reset: h4c 0; }\n"
          ".container h3::before { content: \"" pd "\" counter(h2c) \".\" counter(h3c) \" \"; }\n"
          ".container h4 { counter-increment: h4c; }\n"
          ".container h4::before { content: \"" pd "\" counter(h2c) \".\" counter(h3c) \".\" counter(h4c) \" \"; }\n"))))

(define (add-paras info)
     ; (printf "### add-paras ~s\n" info)
     ; (printf "### first info = ~s\n" (car info))
     ; (printf "### rest info = ~s\n" (add-between (cdr info) (para)))
     (let ([result
             `(,(car info) ,@(add-between (cdr info) (para)))]
             )
       ; (printf "### add-paras result = ~s\n" result)
       result
       ))

(define (bnf . terms)
  "<<BNF pending>>"
  )

(define (nd elem)
  `(span () ,(make-gloss (format "~a-~a" *bnf-type* elem)) "‹" ,elem "›"))

(define (nt elem)
  ; (printf "### nt ~s\n" elem)
  `(span () ,(ref-gloss (format "~a-~a" *bnf-type* elem) (string-append "‹" elem "›"))))

(define (py-prod elem)
  ; (printf "### py-prod ~s\n" elem)
  `(span () ,(ref-gloss (format "~a-~a" "Pyret" elem) (string-append "‹" elem "›"))))

(define (tm elem)
  `(b () ,elem))

(define (tmi elem)
  `(b () (i () ,elem)))

(define *bnf-type* 'Pyret)

(define (ebnf type . elems)
  ; (set! *bnf-type* type)
  (set! elems (map (lambda (s)
                     (if (string? s)
                         (if (string=? s "\n") `(br ())
                             s)
                         s))
                   elems))
  `(div ([class "bnf"])
        ,@elems))

(define (lbrace)
  `(span () "{"))

(define (rbrace)
  `(span () "}"))
