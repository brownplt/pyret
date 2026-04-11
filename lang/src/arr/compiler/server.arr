provide:
  serve
end


import either as E
import json as J
import pathlib as P
import string-dict as SD
import render-error-display as RED
import js-file("server") as S
import file("./cli-module-loader.arr") as CLI
import file("./compile-structs.arr") as CS
import file("./compile-lib.arr") as CL
import file("./query.arr") as Q
import file("locators/builtin.arr") as B

fun get-compile-opts(options):
  opts = CS.make-default-compile-options(options.get-value("this-pyret-dir"))
  opts.{
    base-dir: options.get("base-dir").or-else(opts.base-dir),
    this-pyret-dir : options.get-value("this-pyret-dir"),
    check-mode : not(options.get("no-check-mode").or-else(not(opts.check-mode))),
    type-check : options.get("type-check").or-else(opts.type-check),
    allow-shadowed : options.get("allow-shadowed").or-else(opts.allow-shadowed),
    collect-all: options.get("collect-all").or-else(opts.collect-all),
    ignore-unbound: options.get("ignore-unbound").or-else(opts.ignore-unbound),
    proper-tail-calls: not(options.get("improper-tail-calls").or-else(not(opts.proper-tail-calls))),
    compiled-cache: options.get("compiled-dir").or-else("./compiled"),
    compiled-read-only: options.get("compiled-read-only").or-else(opts.compiled-read-only),
    standalone-file: options.get("standalone-file").or-else(opts.standalone-file),
    checks: options.get("checks").or-else(opts.checks),
    checks-format: options.get("checks-format").or-else(opts.checks-format),
    display-progress: options.get("display-progress").or-else(opts.display-progress),
    log: options.get("log").or-else(opts.log),
    log-error: options.get("log-error").or-else(opts.log-error),
    deps-file: options.get("deps-file").or-else(opts.deps-file),
    user-annotations: options.get("user-annotations").or-else(opts.user-annotations)
  }
end

fun handle-compile-opts(pyret-dir, msg, send-message) block:
  # print("Got message in pyret-land: " + msg)
  opts = J.read-json(msg).native()
  # print(torepr(opts))
  # print("\n")
  when opts.has-key("builtin-js-dir"):
    if is-List(opts.get-value("builtin-js-dir")):
      B.set-builtin-js-dirs(opts.get-value("builtin-js-dir"))
    else:
      B.set-builtin-js-dirs([list: opts.get-value("builtin-js-dir")])
    end
  end
  when opts.has-key("builtin-arr-dir"):
    if is-List(opts.get-value("builtin-arr-dir")):
      B.set-builtin-arr-dirs(opts.get-value("builtin-arr-dir"))
    else:
      B.set-builtin-arr-dirs([list: opts.get-value("builtin-arr-dir")])
    end
  end
  when opts.has-key("allow-builtin-overrides"):
    B.set-allow-builtin-overrides(opts.get-value("allow-builtin-overrides"))
  end
  fun log(s, to-clear):
    d = [SD.string-dict: "type", J.j-str("echo-log"), "contents", J.j-str(s)]
    with-clear = cases(Option) to-clear:
      | none => d.set("clear-first", J.j-bool(false))
      | some(n) => d.set("clear-first", J.j-num(n))
    end
    send-message(J.j-obj(with-clear).serialize())
  end
  fun err(s):
    d = [SD.string-dict: "type", J.j-str("echo-err"), "contents", J.j-str(s)]
    send-message(J.j-obj(d).serialize())
  end
  opts-prime = opts
    .set("log", log)
    .set("log-error", err)
    .set("this-pyret-dir", pyret-dir)
    .set("compiled-read-only", link(P.resolve(P.join(pyret-dir, "lib-compiled")), empty))
  opts-prim2 = if opts.has-key("perilous") and opts.get-value("perilous"):
      opts-prime.set("user-annotations", false)
    else:
      opts-prime
    end
  opts-prim2
    .set("require-config", opts.get("require-config").or-else(P.resolve(P.join(pyret-dir, "config.json"))))
end

fun compile(options):
  outfile = cases(Option) options.get("outfile"):
    | some(v) => v
    | none => options.get-value("program") + ".jarr"
  end
  opts = get-compile-opts(options).{
    cache-manager: CLI.make-file-cache()
  }
  CLI.build-runnable-standalone(
    options.get-value("program"),
    options.get-value("require-config"),
    outfile,
    opts 
  )
end

fun query-compile(options, cache-manager):
  program = options.get-value("program")
  pyret-dir = options.get-value("this-pyret-dir")
  compile-opts = get-compile-opts(options).{
    query: true,
    cache-manager: cache-manager
  }
  CLI.compile-for-query(compile-opts, program)
end

fun on-compile(pyret-dir, msg, send-message):
  opts = handle-compile-opts(pyret-dir, msg, send-message)
  result = run-task(lam(): compile(opts) end)
  cases(E.Either) result block:
    | right(exn) =>
      err-str = RED.display-to-string(exn-unwrap(exn).render-reason(), tostring, empty)
      opts.get-value("log-error")(err-str + "\n")
      d = [SD.string-dict: "type", J.j-str("compile-failure")]
      send-message(J.j-obj(d).serialize())
    | left(val) =>
      d = [SD.string-dict: "type", J.j-str("compile-success")]
      send-message(J.j-obj(d).serialize())
      nothing
  end
end

fun on-query(pyret-dir, cache-manager, query, compile-opts, query-opts, send-message):
  shadow compile-opts = handle-compile-opts(pyret-dir, compile-opts, send-message)
  shadow query-opts = J.read-json(query-opts).native()
  result = run-task(lam():
    base-uri = query-compile(compile-opts, cache-manager)
    # NOTE: To add a new query feature, add a case here and # a function in 
    # query.arr. The cache-manager has surface-ast, named-result, and loadable 
    # for every compiled module.
    ask:
      | query == "jump-to-def" then:
        line = query-opts.get-value("line")
        col = query-opts.get-value("col")
        Q.jump-to-def(cache-manager, base-uri, line, col)
    end
  end)

  err = compile-opts.get-value("log-error")

  cases(E.Either) result block:
    | right(exn) =>
      err-str = RED.display-to-string(exn-unwrap(exn).render-reason(), tostring, empty)
      err(err-str + "\n")
      d = [SD.string-dict: "type", J.j-str(query + "-failure")]
      send-message(J.j-obj(d).serialize())
    | left(info-result) =>
      # NOTE: Each query is responsible for its own response serialization 
      # here, since response shapes differ per feature.
      # TODO: should probably refactor this
      ask:
        | query == "jump-to-def" then:
          cases(E.Either) info-result block:
            | left(error-str) =>
              err("jump-to-def: no result (errors: " + error-str + ")\n")
              d = [SD.string-dict: "type", J.j-str("jump-to-def-failure")]
              send-message(J.j-obj(d).serialize())
            | right(loc-info) =>
              srcloc = loc-info.{1}
              d = [SD.string-dict:
                "type", J.j-str("jump-to-def-success"),
                "uri", J.j-str(loc-info.{0}),
                "start-line", J.j-num(srcloc.start-line),
                "start-column", J.j-num(srcloc.start-column),
                "end-line", J.j-num(srcloc.end-line),
                "end-column", J.j-num(srcloc.end-column)
              ]
              send-message(J.j-obj(d).serialize())
          end
      end
    end
end

fun serve(port, pyret-dir):
  cache-manager = CLI.make-in-memory-cache()
  S.make-server(
    port, 
    on-compile(pyret-dir, _, _),
    on-query(pyret-dir, cache-manager, _, _, _, _)
  )
end
