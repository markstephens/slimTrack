var slimTrack = (function() {

    var version = "**SLIMTRACKVERSION**",
            defaultOptions = {
        clickID: "t" + (new Date()).valueOf(),
        async: true,
        callback: function() {
        }
    };

    function mergeOptions(target, options) {
        // Default is to merge with defaultOptions
        if (!options) {
            options = defaultOptions;
        }

        var name, src, copy;

        for (name in options) {
            src = target[name];
            copy = options[name];

            // Prevent never-ending loop
            if (target === copy) {
                continue;
            }

            // Gets rid of missing values too
            if (typeof copy !== "undefined" && copy !== null) {
                target[name] = copy;
            }
        }

        return target;
    }

    function send(url, options) {
        if (typeof options === "undefined") {
            options = {};
        }

        options = mergeOptions(options);

        var xmlHttp, async = options.async, callback = options.callback, key, query_string = [];
        delete options.async;
        delete options.callback;

        for (key in options) {
            if (options.hasOwnProperty(key)) {
                query_string.push(encodeURIComponent(key) + "=" + encodeURIComponent(options[key]))
            }
        }

        try {
            // code for IE7+, Firefox, Chrome, Opera, Safari
            xmlHttp = new XMLHttpRequest();
        } catch (e) {
            // code for IE6, IE5
            try {
                xmlHttp = new ActiveXObject("Microsoft.XMLHttp");
            } catch (e) {
                // TODO Silently fail or image??
                return false;
            }
        }

        if (async) {
            xmlHttp.onreadystatechange = function() {
                callback(xmlHttp);
            };
        }

        xmlHttp.open("GET", url + '?' + query_string.join('&'), async);
        xmlHttp.send();
        if (!async) {
            callback(xmlHttp);
        }
    }

    function page(options) {
        send('/page', mergeOptions({async: false}, options));
        return this;
    }

    function data(options) {
        send('/data', options);
    }

    function link(options) {
        send('/link', options);
    }

    function event(options) {
        send('/event', options);
    }

    function log(options) {
        send('/log', options);
    }

    return {
        version: version,
        page: page,
        data: data,
        link: link,
        event: event,
        log: log,
        options: defaultOptions
    };
}());
