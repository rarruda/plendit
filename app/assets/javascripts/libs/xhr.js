(function(global) {

    function xhr(method, url, data, headers) {
        var isSuccess = function(n) { return n >= 200 && n < 400; }
        return new Promise(function(resolve, reject) {
            const req = new XMLHttpRequest();
            req.onload = function() { isSuccess(req.status) ? resolve(req) : reject(req) };
            req.onerror = function() { reject(req) };
            req.open(method, url);

            if (headers) {
                for (var key in headers) {
                    req.setRequestHeader(key, headers[key]);
                }
            }

            var csrf = getCsrfData();
            if (csrf.token) {
                req.setRequestHeader("X-CSRF-Token", csrf.token);
            }
            req.send(data);
        });
    }

    function getCsrfData() {
        return {
            param: (document.querySelector('meta[name="csrf-param"]') || {}).content,
            token: (document.querySelector('meta[name="csrf-token"]') || {}).content
        }
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

    function post(url) {
        return xhr("post", url);
    }

    function postForm(url, data) {
        var headers = {
            "Content-type": "application/x-www-form-urlencoded"
        }
        var pairs = [];
        for (var key in data) {
            pairs.push([key, data[key]]);
        }

        var body = pairs
                .map(function(e) { return encodeURIComponent(e[0]) + "=" + encodeURIComponent(e[1]) })
                .join("&");

        return xhr("post", url, body, headers);
    }

    function xhrFormData(formEle) {
        return xhr(formEle.method, formEle.action, new FormData(formEle), {'Accept': 'application/json'});
    }

    global.xhr = { 
        get: get, getJson: getJson, del: del,
        post: post, xhrFormData: xhrFormData,
        postForm: postForm
    };

})(this);