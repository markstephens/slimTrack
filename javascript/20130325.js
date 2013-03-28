var slimTrack = (function() {

    var xmlHttp,
    defaultOptions = {
        clickID: "t" + (new Date()).valueOf(),
        async: true,
        callback: function() {}
    };

    try {
        // code for IE7+, Firefox, Chrome, Opera, Safari
        xmlHttp = new XMLHttpRequest();
    } catch (e) {
        // code for IE6, IE5
        try {
            xmlHttp = new ActiveXObject("Microsoft.XMLHttp");
        } catch (e) {
            // Silently fail
            return false;
        }
    }

    function mergeOptions(target, options) {
        if (!options) {
            options = target;
            target = defaultOptions;
        }

        var name, src, copy;

        for (name in options) {
            src = target[name];
            copy = options[name];

            // Prevent never-ending loop
            if (target === copy) {
                continue;
            }

            if (copy !== undefined) {
                target[ name ] = copy;
            }
        }

        return target;
    }

    function send(url, options) {
        if (typeof options === "undefined") {
            options = {};
        }

        options = mergeOptions(options);

        var async = options.async, callback = options.callback;
        delete options.async;
        delete options.callback;

        if (async) {
            xmlHttp.onreadystatechange = function() {
                callback(xmlHttp);
            };
        }

        xmlHttp.open("GET", url + '?d=' + JSON.stringify(options), async);
        xmlHttp.send();
        if (!async) {
            callback(xmlHttp);
        }
    }

    function page(options) {
        send('/page', mergeOptions({async: false}, options));
        return this;
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
        page: page,
        link: link,
        event: event,
        log: log,
        options: defaultOptions
    };
}());
