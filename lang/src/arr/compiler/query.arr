provide *

# NOTE: New LSP/queries go here as functions that take the cache-manager and 
# query parameters, then return results. The cache-manager has surface-ast, 
# named-result, and loadable for every compiled module.

import either as E
import srcloc as S
import file("compile-structs.arr") as CS

# TODO: debug / figure out where exactly we have to check locations
fun find-name-key-by-srcloc(resolved :: A.Program, srcloc :: Loc) -> Option<String> block:
  var result-mangled-name = none
  visitor = A.default-iter-visitor.{
    # Use sites: s-id(use-l, atom/global) — match on the outer l, return inner key
    method s-id(self, l, id):
      if l == srcloc block:
        result-mangled-name := some(id.key())
        false
      else:
        true
      end
    end,
    method s-id-var(self, l, id):
      if l == srcloc block:
        result-mangled-name := some(id.key())
        false
      else:
        true
      end
    end,
    method s-id-letrec(self, l, id, safe):
      if l == srcloc block:
        result-mangled-name := some(id.key())
        false
      else:
        true
      end
    end,
    # Binding sites: s-atom/s-global appear directly with bind-l — only match
    # if the user clicked exactly on a binding site (rare but possible)
    method s-atom(self, l, base, serial):
      if l == srcloc block:
        result-mangled-name := some(A.s-atom(l, base, serial).key())
        false
      else:
        true
      end
    end,
    method s-global(self, l, s):
      if l == srcloc block:
        result-mangled-name := some(A.s-global(l, s).key())
        false
      else:
        true
      end
    end
  }

  resolved.visit(visitor)
  result-mangled-name
end

is-s-name = A.is-s-name
fun find-name-at(prog :: A.Program, line :: Number, col :: Number) -> Option<A.Name%(is-s-name)> block:
  var result-name = none
  visitor = A.default-iter-visitor.{
    method s-name(self, l, s):
      cases (Loc) l:
        | builtin(_) => true
        | srcloc(_, sl, sc, _, el, ec, _) =>
          if (sl <= line) and (line <= el) and (sc <= col) and (col <= ec) block:
            result-name := some(A.s-name(l, s))
            false
          else:
            true
          end
      end
    end
  }

  prog.visit(visitor)
  result-name
end

fun jump-to-def(cache-manager, uri :: String, line :: Number, col :: Number) -> E.Either<String, {String; S.Srcloc}>:
  cases(Option) cache-manager.get-surface-ast(uri):
    | none => E.left("AST not available")
    | some(ast) =>
      cases(Option) AU.find-name-at(ast, line, col):
        | none => E.left("Did not select an identifier")
        | some(name) =>
          cases(Option) cache-manager.get-named-result(uri):
            | none => E.left("Resolved AST not available")
            | some(named-result) =>
              cases(Option) AU.find-name-key-by-srcloc(named-result.ast, name.l):
                | none => E.left("Post-resolution name not found")
                | some(key) =>
                  cases(Option) named-result.env.bindings.get-now(key):
                    | none => E.left("No identifier binding found")
                    | some(vb) =>
                      E.right({vb.origin.uri-of-definition; vb.origin.definition-bind-site})
                  end
              end
          end
      end
  end
end
