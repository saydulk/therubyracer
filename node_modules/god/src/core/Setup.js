var _utils = require("./Utils.js"),
    _path = require("path"),
    _fs = require("fs");

module.exports = function() {

    return {

        load: function(config) {
            var name, path,
                file,
                configvar,
                module;

            if (config) {
                configvar = _utils.getParams(["name", "path"], config);

                if (configvar.name && configvar.path) {
                    file = _path.resolve(configvar.path , configvar.name, "god.js");
                    if (file && _fs.existsSync(file)) {

                        try {
                            module = new require(file)();
                            console.log("[GOD] I have loaded the module, '" + configvar.name + "'");

                        } catch(e) {
                            console.log("[GOD] Skipping, My attempt to load the requested module failed with errors: ", e);
                        }

                    } else {
                        console.log("[GOD] I'm god but your module request is not making any sense:  '" + configvar.name + "'");
                    }
                }
            }

            return (module ? {name: file, module: module} : undefined);
        }

    };

}();
