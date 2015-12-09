window.plenditUtils = {
    debounce: function debounce(func, wait, immediate) {
        var timeout;
        return function() {
            var context = this, args = arguments;
            var later = function() {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            var callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    },

    geoPromise: function() {
        return new Promise(function(resolve, reject) {
            navigator.geolocation.getCurrentPosition(resolve, reject);
        });
    },

    getCsrfData: function() {
        return {
            param: (document.querySelector('meta[name="csrf-param"]') || {}).content,
            token: (document.querySelector('meta[name="csrf-token"]') || {}).content,
            headerName: 'X-CSRF-Token'
        };
    },

    queryParamsMap: function() {
        return window.location.search
                .slice(1)
                .split("&")
                .map(function(e) { return e.split("="); })
                .reduce(function(acc, cur) { 
                    acc[cur[0]] = cur[1];
                    return acc;
                }, {});
    }
}