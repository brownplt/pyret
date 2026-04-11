provide *
import runtime-lib as R
import builtin-modules as B
import make-standalone as MS
import load-lib as L
import either as E
import json as JSON
import ast as A
import sha as crypto
import string-dict as SD
import render-error-display as RED
import filesystem as Filesystem
import file as F
import error as ERR
import system as SYS
import url as URL
import file("js-ast.arr") as J
import file("concat-lists.arr") as C
import file("compile-lib.arr") as CL
import file("compile-structs.arr") as CS
import file("locators/file.arr") as FL
import file("locators/url.arr") as UL
import file("locators/builtin.arr") as BL
import file("locators/jsfile.arr") as JSF
import file("locators/npm.arr") as NPM
import file("js-of-pyret.arr") as JSP

include from J:
  data JStmt,
  data JExpr,
  data JBlock,
end

include from E:
  data Either
end

include from CS:
  type Loadable
end

clist = C.clist

fun uri-to-path(uri, name):
  name + "-" + crypto.sha256(uri)
end

type CacheManager = {
  cached-available :: (String, String, String, Number -> Option<Any>),
  get-cached :: (String, String, String, Any -> Any),
  get-cached-if-available :: (String, Any -> Any),
  get-loadable :: (String, List<String>, Any, Any -> Option<CL.Loadable>),
  set-loadable :: (String, CL.Locator, CL.Loadable -> String),
  get-builtin-locator :: (String, List<String>, String -> CL.Locator),
  set-surface-ast :: (String, A.Expr -> Nothing),
  get-surface-ast :: (String -> Option<A.Expr>),
  set-named-result :: (String, CS.NameResolution -> Nothing),
  get-named-result :: (String -> Option<CS.NameResolution>)
}

type CacheValue = {
  surface-ast :: Option<A.Expr>, 
  named-result :: Option<CS.NameResolution>,
  loadable :: Option<CL.Loadable>
}

# NOTE(joe): This is just a little one-off type to represent a simple
# situation: Builtin pure-JS files are stored in single files with a hash
# followed by .js, while builtin Pyret files are stored in two files – one with
# just static info and one with all the generated code. The CLI system needs to
# know which kind it is to look up the right cached files

data CachedType:
  | split
  | single-file
end

# NOTE(joe): This has its arguments listed instead of taking a Locator because
# when we have cached, built standalones in releases, we need to do this check
# without constructing a locator that knows about the source. In that case,
# it's fine to pass a modified time of 0 to indicate that we're always happy
# with the compiled version of the file.

fun file-cached-available(basedir, uri, name, modified-time) -> Option<CachedType>:
  saved-path = Filesystem.join(basedir, uri-to-path(uri, name))

  if (Filesystem.exists(saved-path + "-static.js") and
      (Filesystem.stat(saved-path + "-static.js").mtime > modified-time)):
    some(split)
  else if (Filesystem.exists(saved-path + ".js") and
      (Filesystem.stat(saved-path + ".js").mtime > modified-time)):
    some(single-file)
  else:
    none
  end
end

# TODO: this is not currently wired up
# Note: returning an Option is needed for compatibility with `file-cached-available`
fun mem-cached-available(store, basedir, uri, name, _) -> Option<Nothing>:
  key = basedir + uri + name
  if store.has-key-now(key):
    some(nothing)
  else:
    none
  end
end

# Note: `mem-get-cached` and `file-get-cached` both return an object
# with the same methods on it
# TODO: extract this into a better type
fun file-get-cached(basedir, uri, name, cache-type):
  saved-path = Filesystem.join(basedir, uri-to-path(uri, name))
  {static-path; module-path} = cases(CachedType) cache-type:
                # NOTE(joe): leaving off .js because builtin-raw-locator below
                # expects no extension
    | split => {saved-path + "-static"; saved-path + "-module"}
    | single-file => {saved-path; saved-path}
  end
  raw = B.builtin-raw-locator(static-path)
  {
    method get-uncached(_): none end,
    method needs-compile(_, _): false end,
    method get-modified-time(self):
      0
    end,
    method get-options(self, options):
      options.{ checks: "none" }
    end,
    method get-module(_):
      raise("Should never fetch source for builtin module " + static-path)
    end,
    method get-extra-imports(self):
      CS.standard-imports
    end,
    method get-dependencies(_):
      deps = raw.get-raw-dependencies()
      raw-array-to-list(deps).map(CS.make-dep)
    end,
    method get-native-modules(_):
      natives = raw.get-raw-native-modules()
      raw-array-to-list(natives).map(CS.requirejs)
    end,
    method get-globals(_):
      CS.standard-globals
    end,

    method uri(_): uri end,
    method name(_): name end,

    method set-compiled(_, _, _): nothing end,
    method get-compiled(self):
      provs = CS.provides-from-raw-provides(self.uri(), {
          uri: self.uri(),
          values: raw-array-to-list(raw.get-raw-value-provides()),
          aliases: raw-array-to-list(raw.get-raw-alias-provides()),
          datatypes: raw-array-to-list(raw.get-raw-datatype-provides()),
          modules: raw-array-to-list(raw.get-raw-module-provides())
        })
      some(CL.module-as-string(provs, CS.no-builtins, CS.computed-none,
          CS.ok(JSP.ccp-file(Filesystem.resolve(module-path + ".js")))))
    end,

    method _equals(self, other, req-eq):
      req-eq(self.uri(), other.uri())
    end
  }
end

fun mem-get-cached(store, _, uri, name, _):
  {
    method get-uncached(_): none end,
    method needs-compile(_, _): false end,
    method get-modified-time(_): 0 end,
    method get-options(_, options): options.{ checks: "none" } end,
    method get-module(_):
      cases(Option) store.get-now(uri):
        | some(entry) =>
          cases(Option) entry.surface-ast:
            | some(ast) => CL.pyret-ast(ast)
            | none => raise("No cached source for module " + uri)
          end
        | none => raise("No cached source for module " + uri)
      end
    end,
    method get-extra-imports(_):
      if CL.is-builtin-module(uri): CS.minimal-imports
      else: CS.standard-imports
      end
    end,
    method get-dependencies(_):
      cases(Option) store.get-now(uri):
        | some(entry) =>
          cases(Option) entry.surface-ast:
            | some(ast) =>
              if CL.is-builtin-module(uri):
                CL.get-dependencies(CL.pyret-ast(ast), uri)
              else:
                CL.get-standard-dependencies(CL.pyret-ast(ast), uri)
              end
            | none => empty
          end
        | none => empty
      end
    end,
    method get-native-modules(_): [list:] end,
    method get-globals(_): CS.standard-globals end,
    method uri(_): uri end,
    method name(_): name end,
    method set-compiled(_, _, _): nothing end,
    method get-compiled(_):
      cases(Option) store.get-now(uri):
        | some(entry) => entry.loadable
        | none => none
      end
    end,
    method _equals(self, other, req-eq):
      req-eq(self.uri(), other.uri())
    end
  }
end


fun get-cached-if-available(cache-manager, basedir, loc) block:
  get-cached-if-available-known-mtimes(cache-manager, basedir, loc, [SD.string-dict:])
end
fun get-cached-if-available-known-mtimes(cache-manager, basedir, loc, max-dep-times) block:
  saved-path = Filesystem.join(basedir, uri-to-path(loc.uri(), loc.name()))
  dependency-based-mtime =
    if max-dep-times.has-key(loc.uri()): max-dep-times.get-value(loc.uri())
    else: loc.get-modified-time()
    end
  cached-type = cache-manager.cached-available(basedir, loc.uri(), loc.name(), dependency-based-mtime)
  cases(Option) cached-type:
    | none =>
      cases(Option) loc.get-uncached():
        | some(shadow loc) => loc
        | none => loc
      end

    | some(ct) => cache-manager.get-cached(basedir, loc.uri(), loc.name(), ct).{
        method get-uncached(self): some(loc) end
      }
  end
end

fun get-file-locator(cache-manager, basedir, real-path):
  loc = FL.file-locator(real-path, CS.standard-globals)
  get-cached-if-available(cache-manager, basedir, loc)
end

fun file-get-builtin-locator(cache-manager, basedir, read-only-basedirs, modname):
  all-dirs = read-only-basedirs

  first-available = for find(rob from all-dirs):
    is-some(cache-manager.cached-available(rob, "builtin://" + modname, modname, 0))
  end
  cases(Option) first-available:
    | none =>
      cases(Option) BL.maybe-make-builtin-locator(modname) block:
        | some(loc) =>
          get-cached-if-available(cache-manager, basedir, loc)
        | none =>
          raise("Could not find builtin module " + modname + " in any of " + all-dirs.join-str(", "))
      end
    | some(ro-basedir) =>
      ca = cache-manager.cached-available(ro-basedir, "builtin://" + modname, modname, 0).or-else(split)
      cache-manager.get-cached(ro-basedir, "builtin://" + modname, modname, ca)
  end
end

fun get-builtin-test-locator(cache-manager, basedir, modname):
  loc = BL.make-builtin-locator(modname).{
    method uri(_): "builtin-test://" + modname end
  }
  cache-manager.get-cached-if-available(basedir, loc)
end

fun get-loadable-impl(cache-manager, basedir, read-only-basedirs, l, max-dep-times) -> Option<Loadable>:
  locuri = l.locator.uri()
  first-available = for find(rob from link(basedir, read-only-basedirs)):
    is-some(cache-manager.cached-available(rob, l.locator.uri(), l.locator.name(), max-dep-times.get-value(locuri)))
  end
  cases(Option) first-available block:
    | none => none
    | some(found-basedir) =>
      c = cache-manager.cached-available(found-basedir, l.locator.uri(), l.locator.name(), max-dep-times.get-value(locuri))
      saved-path = Filesystem.join(found-basedir, uri-to-path(locuri, l.locator.name()))
      {static-path; module-path} = cases(CachedType) c.or-else(single-file):
        | split =>
          {saved-path + "-static"; saved-path + "-module.js"}
        | single-file =>
          {saved-path; saved-path + ".js"}
      end
      raw-static = B.builtin-raw-locator(static-path)
      provs = CS.provides-from-raw-provides(locuri, {
        uri: locuri,
        modules: raw-array-to-list(raw-static.get-raw-module-provides()),
        values: raw-array-to-list(raw-static.get-raw-value-provides()),
        aliases: raw-array-to-list(raw-static.get-raw-alias-provides()),
        datatypes: raw-array-to-list(raw-static.get-raw-datatype-provides())
      })
      some(CS.module-as-string(provs, CS.no-builtins, CS.computed-none, CS.ok(JSP.ccp-file(module-path))))
  end
end

fun set-loadable(basedir, locator, loadable) -> String block:
  doc: "Returns the module path of the cached file"
  when not(Filesystem.exists(basedir)):
    Filesystem.create-dir(basedir)
  end
  locuri = loadable.provides.from-uri
  cases(CS.CompileResult) loadable.result-printer block:
    | ok(ccp) =>
      save-static-path = Filesystem.join(basedir, uri-to-path(locuri, locator.name()) + "-static.js")
      save-module-path = Filesystem.join(basedir, uri-to-path(locuri, locator.name()) + "-module.js")
      fs = F.output-file(save-static-path, false)
      fm = F.output-file(save-module-path, false)

      ccp.print-js-runnable(fm.display)

      # NOTE(joe August 2017): This is a little bit dumb. When caching a file,
      # if we have enough information, split it into -static and -module
      # pieces.  If we don't have a dictionary of this information, save two
      # copies of it. We simply don't have enough metadata floating around to
      # make good decisions at fetch time. The copying is fairly innocuous,
      # because it only happens for hand-written JS files, which are smaller.
      # But this is a point to revisit.

      if JSP.is-ccp-dict(ccp):
        ccp.print-js-static(fs.display)
      else:
        ccp.print-js-runnable(fs.display)
      end

      fs.flush()
      fs.close-file()
      fm.flush()
      fm.close-file()

      save-module-path
    | err(_) => ""
  end
end

type CLIContext = {
  current-load-path :: String,
  cache-base-dir :: String,
  compiled-read-only-dirs :: List<String>,
  url-file-mode :: CS.UrlFileMode
}

fun get-real-path(current-load-path :: String, this-path :: String):
  if Filesystem.is-absolute(this-path):
    this-path
  else:
    Filesystem.join(current-load-path, this-path)
  end
end

fun maybe-add-slash(s):
  last-index = string-length(s) - 1
  if string-char-at(s, last-index) == "/": s
  else: s + "/"
  end
end

fun locate-file(cache-manager :: CacheManager, ctxt :: CLIContext, rel-path :: String):
  clp = ctxt.current-load-path
  real-path = get-real-path(clp, rel-path)
  new-context = ctxt.{current-load-path: Filesystem.dirname(real-path)}
  if Filesystem.exists(real-path):
    some(CL.located(get-file-locator(cache-manager, ctxt.cache-base-dir, real-path), new-context))
  else:
    none
  end
end
fun module-finder-with(cache-manager :: CacheManager, ctxt :: CLIContext, dep :: CS.Dependency):
  shadow locate-file = locate-file(cache-manager, _, _)
  cases(CS.Dependency) dep:
    | dependency(protocol, args) =>
      if protocol == "file":
        cases(Option) locate-file(ctxt, args.get(0)):
          | some(located) => located
          | none => raise("Cannot find import " + torepr(dep))
        end
      else if protocol == "url":
        CL.located(UL.url-locator(dep.arguments.get(0), CS.standard-globals), ctxt)
      else if protocol == "url-file":
        base = maybe-add-slash(args.get(0))
        full-url = URL.resolve(args.get(1), base)
        cases(CS.UrlFileMode) ctxt.url-file-mode:
          | all-remote =>
            CL.located(UL.url-locator(full-url, CS.standard-globals), ctxt)
          | all-local =>
            cases(Option) locate-file(ctxt, args.get(1)):
              | some(located) =>
                locator-with-uri = located.locator.{ method uri(self): full-url end }
                CL.located(locator-with-uri, located.context)
              | none => raise("Cannot find import " + torepr(dep))
            end
          | local-if-present =>
            cases(Option) locate-file(ctxt, args.get(1)):
              | some(located) =>
                locator-with-uri = located.locator.{ method uri(self): full-url end }
                CL.located(locator-with-uri, located.context)
              | none =>
                CL.located(UL.url-locator(full-url, CS.standard-globals), ctxt)
            end
        end
      else if protocol == "npm":
        package-name = args.get(0)
        path = args.get(1)
        locator = NPM.make-npm-locator(package-name, path, ctxt.current-load-path)
        clp = ctxt.current-load-path
        real-path = get-real-path(clp, locator.path)
        new-context = ctxt.{current-load-path: Filesystem.dirname(real-path)}
        CL.located(locator, new-context)
      else if protocol == "builtin-test":
        l = get-builtin-test-locator(cache-manager, ctxt.cache-base-dir, args.first)
        force-check-mode = l.{
          method get-options(self, options):
            options.{ checks: "all", type-check: false }
          end
        }
        CL.located(force-check-mode, ctxt)
      else if protocol == "file-no-cache":
        clp = ctxt.current-load-path
        real-path = get-real-path(clp, args.get(0))
        new-context = ctxt.{current-load-path: Filesystem.dirname(real-path)}
        if Filesystem.exists(real-path):
          CL.located(FL.file-locator(real-path, CS.standard-globals), new-context)
        else:
          raise("Cannot find import " + torepr(dep))
        end
      else if protocol == "js-file":
        clp = ctxt.current-load-path
        real-path = get-real-path(clp, args.get(0))
        new-context = ctxt.{current-load-path: Filesystem.dirname(real-path)}
        locator = JSF.make-jsfile-locator(real-path)
        CL.located(locator, new-context)
      else:
        raise("Unknown import type: " + protocol)
      end
    | builtin(modname) =>
      CL.located(file-get-builtin-locator(cache-manager, ctxt.cache-base-dir, ctxt.compiled-read-only-dirs, modname), ctxt)
  end
end


default-start-context = {
  current-load-path: Filesystem.resolve("./"),
  cache-base-dir: Filesystem.resolve("./compiled"),
  compiled-read-only-dirs: empty,
  url-file-mode: CS.all-remote
}

default-test-context = {
  current-load-path: Filesystem.resolve("./"),
  cache-base-dir: Filesystem.resolve("./tests/compiled"),
  compiled-read-only-dirs: empty,
  url-file-mode: CS.all-remote
}

fun compile(path, options):
  base-module = CS.dependency("file", [list: path])
  shadow module-finder = module-finder-with(options.cache-manager, _, _)
  base = module-finder({
    current-load-path: Filesystem.resolve(options.base-dir),
    cache-base-dir: options.compiled-cache,
    compiled-read-only-dirs: options.compiled-read-only.map(Filesystem.resolve),
    url-file-mode: options.url-file-mode
  }, base-module)
  wl = CL.compile-worklist(module-finder, base.locator, base.context)
  compiled = CL.compile-program(wl, options)
  compiled
end

fun handle-compilation-errors(problems, options) block:
  for lists.each(e from problems) block:
    options.log-error(RED.display-to-string(e.render-reason(), torepr, empty))
    options.log-error("\n")
  end
  raise("There were compilation errors")
end

fun propagate-exit(result) block:
  when L.is-exit(result):
    code = L.get-exit-code(result)
    SYS.exit(code)
  end
  when L.is-exit-quiet(result):
    code = L.get-exit-code(result)
    SYS.exit-quiet(code)
  end
end

fun make-file-cache() -> CacheManager:
  {
    cached-available: file-cached-available,
    get-cached: file-get-cached,
    method get-cached-if-available(self, basedir, loc):
      get-cached-if-available(self, basedir, loc)
    end,
    method get-loadable(self, basedir, read-only-basedirs, l, max-dep-times):
      get-loadable-impl(self, basedir, read-only-basedirs, l, max-dep-times)
    end,
    method set-loadable(self, basedir, locator, loadable):
      set-loadable(basedir, locator, loadable)
    end,
    method get-builtin-locator(self, basedir, read-only-basedirs, modname):
      file-get-builtin-locator(self, basedir, read-only-basedirs, modname)
    end,
    method set-surface-ast(self, _, _): nothing end,
    method get-surface-ast(self, _): none end,
    method set-named-result(self, _, _): nothing end,
    method get-named-result(self, _): none end,
  }
end

fun make-in-memory-cache() -> CacheManager:
  store :: SD.MutableStringDict<CacheValue> = [SD.mutable-string-dict:]

  fun get-entry(uri):
    store.get-now(uri)
  end

  fun update-entry(uri, updater):
    existing = cases(Option) store.get-now(uri):
      | some(v) => v
      | none => { surface-ast: none, named-result: none, loadable: none }
    end
    store.set-now(uri, updater(existing))
  end

  {
    # TODO: falling back to file-based lookup for builtins is a workaround;
    # ideally builtins would be loaded into the in-memory store directly
    cached-available: lam(basedir, uri, name, mtime):
      if store.has-key-now(uri): some(nothing)
      else if string-index-of(uri, "builtin://") == 0:
        file-cached-available(basedir, uri, name, mtime)
      else: none
      end
    end,
    get-cached: lam(basedir, uri, name, cache-type):
      if store.has-key-now(uri):
        mem-get-cached(store, basedir, uri, name, cache-type)
      else if string-index-of(uri, "builtin://") == 0:
        file-get-cached(basedir, uri, name, cache-type)
      else:
        raise("No in-memory cache entry for non-builtin module " + uri)
      end
    end,
    method get-cached-if-available(self, _, loc):
      if store.has-key-now(loc.uri()):
        self.get-cached("", loc.uri(), loc.name(), nothing).{
          method get-uncached(_): some(loc) end
        }
      else:
        cases(Option) loc.get-uncached():
          | some(shadow loc) => loc
          | none => loc
        end
      end
    end,
    method get-loadable(self, basedir, read-only-basedirs, l, max-dep-times):
      cases(Option) get-entry(l.locator.uri()):
        | some(e) => e.loadable
        | none =>
          # Fall back to file-based lookup for builtins so they land in
          # starter-modules and skip compile-module entirely.
          if string-index-of(l.locator.uri(), "builtin://") == 0:
            get-loadable-impl(self, basedir, read-only-basedirs, l, max-dep-times)
          else:
            none
          end
      end
    end,
    method set-loadable(self, _, locator, loadable) block:
      update-entry(locator.uri(), lam(e): e.{loadable: some(loadable)} end)
      locator.uri()
    end,
    # TODO: builtins should be loaded into the in-memory store rather than
    # going through file-based lookup. Blocked on having a serialization
    # format for Loadable that doesn't depend on the JS file infrastructure
    # (builtin-raw-locator / -static.js / -module.js).
    method get-builtin-locator(self, basedir, read-only-basedirs, modname):
      file-get-builtin-locator(self, basedir, read-only-basedirs, modname)
    end,
    method set-surface-ast(self, uri, ast):
      update-entry(uri, lam(e): e.{surface-ast: some(ast)} end)
    end,
    method get-surface-ast(self, uri):
      cases(Option) get-entry(uri):
        | some(e) => e.surface-ast
        | none => none
      end
    end,
    method set-named-result(self, uri, named-result):
      update-entry(uri, lam(e): e.{named-result: some(named-result)} end)
    end,
    method get-named-result(self, uri):
      cases(Option) get-entry(uri):
        | some(e) => e.named-result
        | none => none
      end
    end,
  }
end

fun run(path, options, subsequent-command-line-arguments):
  stats = SD.make-mutable-string-dict()
  maybe-program = build-program(path, options, stats)
  cases(Either) maybe-program block:
    | left(problems) =>
      handle-compilation-errors(problems, options)
    | right(program) =>
      command-line-arguments = link(path, subsequent-command-line-arguments)
      result = L.run-program(R.make-runtime(), L.empty-realm(), program.js-ast.to-ugly-source(), options, command-line-arguments)
      if L.is-success-result(result):
        L.render-check-results(result, options.checks-format)
      else:
        _ = propagate-exit(result)
        L.render-error-message(result)
      end
  end
end

# TODO: this shares a lot of commonality with `build-program`.
fun compile-for-query(options, program) block:
  base-module = CS.dependency("file", [list: program])
  shadow module-finder = module-finder-with(options.cache-manager, _, _)
  base = module-finder({
    current-load-path: Filesystem.resolve(options.base-dir),
    cache-base-dir: options.compiled-cache,
    compiled-read-only-dirs: options.compiled-read-only.map(Filesystem.resolve),
    url-file-mode: options.url-file-mode
  }, base-module)
  wl = CL.compile-worklist(module-finder, base.locator, base.context)
  # starter-modules = CL.modules-from-worklist(wl,
  #   lam(l, _): cache-manager.get-loadable("", empty, l, [SD.string-dict:]) end)
  starter-modules = CL.modules-from-worklist(wl, options.cache-manager.get-loadable(options.compiled-cache, options.compiled-read-only.map(Filesystem.resolve), _, _))
  CL.compile-program-with(wl, starter-modules, options)
  base.locator.uri()
end

fun build-program(path, options, stats) block:
  doc: ```Returns the program as a JavaScript AST of module list and dependency map,
          and its native dependencies as a list of strings```

  # TODO: this should probably refactored into default opts
  shadow options = options.{
    cache-manager: if options.query: make-in-memory-cache() else: make-file-cache() end
  }

  print-progress-clearing = lam(s, to-clear):
    when options.display-progress:
      options.log(s, to-clear)
    end
  end
  print-progress = lam(s): print-progress-clearing(s, none) end
  var str = "Gathering dependencies..."
  fun clear-and-print(new-str) block:
    print-progress-clearing(new-str, some(string-length(str)))
    str := new-str
  end
  print-progress(str)
  base-module = CS.dependency("file", [list: path])
  shadow module-finder = module-finder-with(options.cache-manager, _, _)
  base = module-finder({
    current-load-path: Filesystem.resolve(options.base-dir),
    cache-base-dir: options.compiled-cache,
    compiled-read-only-dirs: options.compiled-read-only.map(Filesystem.resolve),
    url-file-mode: options.url-file-mode
  }, base-module)
  clear-and-print("Compiling worklist...")
  wl = CL.compile-worklist(module-finder, base.locator, base.context)

  max-dep-times = CL.dep-times-from-worklist(wl)

  shadow wl = for map(located from wl):
    located.{ locator: get-cached-if-available-known-mtimes(options.cache-manager, options.compiled-cache, located.locator, max-dep-times) }
  end

  clear-and-print("Loading existing compiled modules...")

  starter-modules = CL.modules-from-worklist(wl,
    options.cache-manager.get-loadable(options.compiled-cache, options.compiled-read-only.map(Filesystem.resolve), _, _))

  cached-modules = starter-modules.count-now()
  total-modules = wl.length() - cached-modules
  var num-compiled = 0
  when total-modules == 0:
    clear-and-print("All modules already compiled. Cleaning up and generating standalone...\n")
  end
  shadow options = options.{
    method should-profile(_, locator):
      options.add-profiling and (locator.uri() == base.locator.uri())
    end,
    method before-compile(_, locator) block:
      num-compiled := num-compiled + 1
      clear-and-print("Compiling " + num-to-string(num-compiled) + "/" + num-to-string(total-modules)
          + ": " + locator.name())
    end,
    method on-compile(_, locator, loadable, trace) block:
      locator.set-compiled(loadable, SD.make-mutable-string-dict()) # TODO(joe): What are these supposed to be?
      clear-and-print(num-to-string(num-compiled) + "/" + num-to-string(total-modules)
          + " modules compiled " + "(" + locator.name() + ")")
      when options.collect-times:
        comp = for map(stage from trace):
          stage.name + ": " + tostring(stage.time) + "ms"
        end
        stats.set-now(locator.name(), comp)
      end
      when num-compiled == total-modules:
        print-progress("\nCleaning up and generating standalone...\n")
      end
      module-path = set-loadable(options.compiled-cache, locator, loadable)
      if (num-compiled == total-modules) and options.collect-all:
        # Don't squash the final JS-AST if we're collecting all of them, so
        # it can be pretty-printed after all
        loadable
      else:
        cases(CS.Loadable) loadable:
          | module-as-string(prov, env, post-env, rp) =>
            CS.module-as-string(prov, env, post-env, CS.ok(JSP.ccp-file(module-path)))
          | else => loadable
        end
      end
    end
  }
  ans = CL.compile-standalone(wl, starter-modules, options)
  ans
end

fun build-runnable-standalone(path, require-config-path, outfile, options) block:
  stats = SD.make-mutable-string-dict()
  config = JSON.read-json(Filesystem.read-file-string(require-config-path)).dict.unfreeze()
  cases(Option) config.get-now("typable-builtins"):
    | none => nothing
    | some(tb) =>
      cases(JSON.JSON) tb:
        | j-arr(l) =>
          BL.set-typable-builtins(l.map(_.s))
        | else => raise("Expected a list for typable-builtins, but got: " + to-repr(tb))
      end
  end
  maybe-program = build-program(path, options, stats)
  cases(Either) maybe-program block:
    | left(problems) =>
      handle-compilation-errors(problems, options)
    | right(program) =>
      shadow require-config-path = get-real-path(options.base-dir, require-config-path)

      config.set-now("out", JSON.j-str(get-real-path(options.base-dir, outfile)))
      when not(config.has-key-now("baseUrl")):
        config.set-now("baseUrl", JSON.j-str(options.compiled-cache))
      end

      when options.collect-times: stats.set-now("standalone", time-now()) end
      make-standalone-res = MS.make-standalone(program.natives, program.js-ast,
        JSON.j-obj(config.freeze()).serialize(), options)

      html-res = if is-some(options.html-file):
        MS.make-html-file(outfile, options.html-file.value)
      else:
        true
      end

      ans = make-standalone-res and html-res

      when options.collect-times block:
        standalone-end = time-now() - stats.get-value-now("standalone")
        stats.set-now("standalone", [list: "Outputing JS: " + tostring(standalone-end) + "ms"])
        for SD.each-key-now(key from stats):
          print(key + ": \n" + stats.get-value-now(key).join-str(", \n") + "\n")
        end
      end
      ans
  end
end

fun build-require-standalone(path, options):
  stats = SD.make-mutable-string-dict()
  program = build-program(path, options, stats)

  natives = j-list(true, for C.map_list(n from program.natives): n end)

  define-name = j-id(A.s-name(A.dummy-loc, "define"))

  prog = j-block([clist:
      j-app(define-name, [clist: natives, j-fun(J.next-j-fun-id(), [clist:],
        j-block([clist:
          j-return(program.js-ast)
        ]))
      ])
    ])

  print(prog.to-ugly-source())
end


# backwards compatibility
module-finder = module-finder-with(make-file-cache(), _, _)
