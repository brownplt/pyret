#lang racket/base

(module setup racket
  (provide (all-defined-out))
  ; The (not (string-suffix)) makes sure that we don't omit the entire
  ; directory. But then omit everything that's a subdir that is NOT the thing we
  ; want
  (define (keep-subdir ps base subdir)
      (and
          (not (string-suffix? ps base))
          (string-contains? ps base)
          (not (string-contains? ps subdir))))
  (define (omitted-path? p) 
    (define ps (path->string p))
    (or (keep-subdir ps "node_modules" "pyret-embed")
        (keep-subdir ps "site" "js")
        (string-suffix? ps "typescript"))))

(provide link/new-tab)

(define (link/new-tab url . bodies)
  `(a ([href ,url]
       [target "_blank"])
      ,@bodies))
