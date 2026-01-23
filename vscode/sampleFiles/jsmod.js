({
    requires: [],
    provides: {
        values: {
            x: "Number"
        }
    },
    nativeRequires: [],
    theModule: function(runtime, _, uri) {
        return runtime.makeModuleReturn({
            x: 100
        }, {});
    }
})