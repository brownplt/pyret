check "https://github.com/brownplt/pyret-lang/issues/1700":
  letrec n :: Number%(is-zero) = 10, is-zero = lam(x): x == 0 end: n end
    raises "uninitialized-id"
 
  letrec is-zero = lam(x): x == 0, n :: Number%(is-zero) = 10 end: n end
    raises "type-mismatch"
end
