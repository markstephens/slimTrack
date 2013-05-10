var slimTrack = (function() {
    var version = "**SLIMTRACKVERSION**",
            pageSent = false,
            defaultOptions = {
        clickID: "t" + (new Date()).valueOf(),
        async: true,
        callback: function() {
        },
        co: window.screen.colorDepth,
        sr: window.screen.width + 'x' + window.screen.height,
        lt: (new Date()).toISOString(),
        referer: document.referrer
    };

    function clone(target, options) {
        if (!options) {
            options = target;
            target = {};
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

    function mergeOptions(target, options) {
        // Default is to merge with defaultOptions
        if (!options) {
            options = target;
            target = clone(defaultOptions);
        }

        return clone(target, options);
    }

    function send(url, options) {
        if (typeof options === "undefined") {
            options = {};
        }

        options = mergeOptions(options);

        var params = clone(options), // Stop issue when deleting params and JS holding objects in reference
                xmlHttp, async = options.async, callback = options.callback, key, query_string = [], sent_url, callback_scope;
        delete params.async;
        delete params.callback;

        for (key in params) {
            if (params.hasOwnProperty(key)) {
                query_string.push(encodeURIComponent(key) + "=" + encodeURIComponent(params[key]))
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

        sent_url = url + '?' + query_string.join('&');
        callback_scope = {url: sent_url, async: async, params: params};

        if (async) {
            xmlHttp.onreadystatechange = function() {
                callback.call(callback_scope, xmlHttp);
            };
        }

        xmlHttp.open("GET", sent_url, async);
        xmlHttp.send();
        if (!async) {
            callback.call(callback_scope, xmlHttp);
        }
    }

    function page(options) {
        if (pageSent) {
            throw 'PageTrack already sent';
        }
        send('/page', mergeOptions({async: false}, options));
        pageSent = true;
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
