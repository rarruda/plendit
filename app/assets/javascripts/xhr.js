(function(global) {

    function xhr(method, url, data) {
        var isSuccess = function(n) { return n >= 200 && n < 400; }
        return new Promise(function(resolve, reject) {
            const req = new XMLHttpRequest();
            req.onload = function() { isSuccess(req.status) ? resolve(req) : reject(req) };
            req.onerror = function() { reject(req) };
            req.open(method, url);
            req.send(data);
        });
    }

    function get(url) {
        return xhr("get", url);
    }

    function getJson(url) {
        return get(url).then(function(e) {
            return JSON.parse(e.responseText);
        });
    }

    function del(url) {
        return xhr("delete", url);
    }

    global.xhr = { get: get, getJson: getJson, del: del };
    
})(this);

