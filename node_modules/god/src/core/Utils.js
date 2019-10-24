//var _typedas = require("typedas") 

module.exports = function() {

    return {

        getParams: function(keys, obj) {
            var result = {};

//            if ( (obj && keys && _typedas.isArray(keys)) ) {
//
//                keys.forEach(function(key){
//                    result[key] = ( (key in obj) ? obj[key]: undefined);
//                });
//
//            }

            return result;
        }

    };

}();
