

function Test1() {

    var configvar,
        god = require("./../god.js"),
        modules, key;

    if (god) {
        god.create({plugins:["nodejs"]});

        modules = god.modules();
        for (key in modules) {
            console.log("\n module, ", modules[key]);
        }

    }
}

Test1();