var Track = (function(slimTrack) {
    
    function getValueFromUrl(matcher) {
        return document.location.href.match(matcher) && RegExp.$1 !== "" ? RegExp.$1 : null;
    }

    function getValueFromCookie(matcher) {
        return document.cookie.match(matcher) && RegExp.$1 !== "" && RegExp.$1 !== "null" ? RegExp.$1 : null;
    }

    function getValueFromJsVariable(str) {
        if (typeof str !== "string") {
            return null;
        }

        var i, namespaces = str.split('.'), test = window;

        for (i = 0; i < namespaces.length; i = i + 1) {
            if (typeof test[namespaces[i]] === "undefined") {
                return null;
            }

            test = test[namespaces[i]];
        }

        return test !== "" ? test : null;
    }

    return {
        page: function() {
            slimTrack.page({
                uuid: getValueFromUrl(/\/cms\/s?\/?\d?\/?([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})/), // TODO Example - could get this serverside
                pid_s: getValueFromCookie(/USERID=([0-9]*):/), // TODO Example - could get this serverside
                dfp_site: getValueFromJsVariable("FT.env.dfp_site"), // Dart for Publishers advertising site
                dfp_zone: getValueFromJsVariable("FT.env.dfp_zone"), // Dart for Publishers advertising zone
                dfp_targeting: getValueFromJsVariable("FT.env.dfp_targeting")  // Dart for Publishers advertising targeting
            });
        },
                
        event: slimTrack.event
    };

}(slimTrack));