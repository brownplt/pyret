({
    provides: {
        values: { "x": "Number" },
        types: {}
    },
    requires: [],
    nativeRequires: [],
    theModule: function(runtime, _, _) {
        return runtime.makeModuleReturn({
            x: 42
        }, {});
    }
})