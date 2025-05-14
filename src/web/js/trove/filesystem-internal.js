/**
 * This file overrides the filesystem-internal.js module in pyret-lang.
 * It only makes sense to use this library when an embedding context is
 * providing appropriate RPC calls.
 */
({
    provides: {
        values: {},
        types: {}
    },
    requires: [],
    nativeRequires: [],
    theModule: function(runtime, _, _) {
        let initializedOK = true;
        if(!window.MESSAGES) {
            initializedOK = false;
            console.error("No MESSAGES object found. filesystem-internal on the web requires an embedding context to provide RPC calls.");
        }
        function wrap(f) {
            return async function(...args) {
                if(!initializedOK) {
                    throw runtime.ffi.makeMessageException(`filesystem-internal: Cannot call ${f.name} because fs.promises not available`)
                }
                return f(...args);
            }
        }
        async function readFile(p) {
            return window.MESSAGES.sendRpc('fs', 'readFile', [p]);
        }
        async function writeFile(p, data) {
            return window.MESSAGES.sendRpc('fs', 'writeFile', [p, data]);
        }
        async function stat(p) {
            return window.MESSAGES.sendRpc('fs', 'stat', [p]);
        }
        async function resolve(...paths) {
            return window.MESSAGES.sendRpc('path', 'resolve', paths);
        }
        return runtime.makeJSModuleReturn({
            readFile: wrap(readFile),
            writeFile: wrap(writeFile),
            stat: wrap(stat),
            resolve: wrap(resolve),
            init: initializedOK
        });
    }
})
