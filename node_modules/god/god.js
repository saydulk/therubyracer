var _utils = require("./src/core/Utils.js"),
    _setup = require("./src/core/Setup.js");

module.exports =  function() {

    var _modules = {};

    (function(){



    })();

    return {

        command: function(config) {

        },

        create: function(config) {

            var configvar = _utils.getParams(["plugins"], config),
                module;

            if (configvar) {
                if (configvar.plugins) {
                    configvar.plugins.forEach(function(plugin) {
                        if (plugin) {
                            module = _setup.load({
                                    name: plugin,
                                    path: "./src/being"
                                }
                            );
                            if (module) {
                                _modules[module.name] = module.module;
                            }
                        }
                    });
                }
            }
        },

        modules: function() {
            return _modules;
        }

    };

}();