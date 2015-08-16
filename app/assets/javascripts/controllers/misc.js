window.controllers = window.controllers || {};
window.services = window.services || {};

window.services.responsive = {
    name: "responsive",
    callable: function() {

        function isGriddy() {
            return window.innerWidth < 640;
        }

        return {
            isGriddy: isGriddy
        }
    }
}

window.controllers.postalPlaceFetcher = {
    callable: function(ele) {
        var lastSeen = "";
        var source = ele.querySelector("[data-postal-code]");
        var target = ele.querySelector("[data-postal-place]");
        var baseUrl = ele.getAttribute("data-postal-place-url");
        init();

        function init() {
            source.addEventListener('change', fetchPostalPlace);
            source.addEventListener('keyup', fetchPostalPlace);
            source.addEventListener('blur', fetchPostalPlace);
        }

        function fetchPostalPlace(evt) {
            if (lastSeen != evt.target.value) {
                lastSeen = evt.target.value;
                var url = baseUrl + "?postal_code=" + evt.target.value;
                xhr.get(url).then(updatePostalPlace);
            }
        }

        function updatePostalPlace(xhr) {
            target.value = xhr.responseText;
        }
    }
};

window.controllers.resetUnseenNotificationCount = function(ele) {
    var hasBeenReset = false;
    ele.addEventListener('click', function() {
        if (!hasBeenReset) {
            hasBeenReset = true;
            var url = ele.getAttribute("data-clear-notifications-url");
            xhr.post(url);
            var countEle = ele.querySelector("[data-notification-count]");
            if (countEle) {
                countEle.classList.add('u-hidden');
            }
        }
    });
}

window.controllers.resultContainerSizeAdjuster = {
    dependencies: ["$element", "eventbus"],
    callable: function(ele, eventBus) {
        window.addEventListener('resize', adjustHeight);
        eventBus.on('filter-toggle', adjustHeight);
        adjustHeight();

        function adjustHeight() {
            var height = window.innerHeight - ele.offsetTop;
            ele.style.height = height + "px";
        }
    }
}

window.services.searchService = {
    name: "searchService",
    dependencies: ["eventbus"],
    callable: function(eventBus) {
        var params = {};
        var bounds = {};
        var zl = {};
        var mostRecentResult;

        var queryBlackList = {
            utf8: true,
            authenticity_token: true
        }

        init();

        function init() {
            var jsonContainer = document.querySelector("[data-location-info]");
            mostRecentResult = JSON.parse(jsonContainer.textContent);

            var parts = window
                .location.search.split(/[\?&]/)
                .filter(function(e) { return e; })
                .map(function(e) { return e.split('='); });

            parts
                .filter(boundsFilter)
                .forEach(function(e) {
                    bounds[e[0]] = e[1];
                });
            parts
                .filter(invertFilter(boundsFilter))
                .forEach(function(e) {
                    params[e[0]] = e[1];
                });
        }

        function boundsFilter(e) {
            return ['ne_lat', 'ne_lon', 'sw_lat', 'sw_lon'].indexOf(e[0]) != -1;
        }

        function invertFilter(fun) {
            return function(e) { return !fun(e); }
        }

        function merge(a,b) {
            var ret = {};
            var key;
            for (key in a) { ret[key] = a[key] }
            for (key in b) { ret[key] = b[key] }
            return ret;
        }

        function search(form) {
            params = form;
            form = merge(form, bounds);
            form = merge(form, zl);

            var url = '/search.json?' + buildQuery(form);
            history.replaceState(null, null, url.replace(".json", ""));
            xhr.get(url).then(onSearchFinished);
        }

        function setBounds(b) {
            bounds = b;
            search(params);
        }

        function setZoom(zoom) {
            zl = zoom;
        }

        function resultsAreDifferent(first, second) {
            return idKeyFromResult(first) != idKeyFromResult(second);
        }

        function idKeyFromResult(result) {
            if (result && result.hits) {
                var ids = result.hits.map(function(e) { return e.id; });
                ids.sort();
                return ids.join(",");
            }
            else {
                return "";
            }
        }

        function onSearchFinished(response) {
            var result = JSON.parse(response.responseText);
            if (resultsAreDifferent(result, mostRecentResult)) {
                mostRecentResult = result;
                eventBus.emit('new-search-result', result);
            }
        }

        function buildQuery(form) {
            var items = [];
            for (var key in form) {
                items.push({key: key, value: form[key]});
            }

            items = items.filter(function(e) {
                return !queryBlackList[e.key];
            });

            items = items.map(function(e) {
                return e.key + "=" + e.value;
            });

            return items.join("&");
        }

        return {
            search: search,
            setBounds: setBounds,
            setZoom: setZoom,
            getMostRecentSearchResult: function() { return mostRecentResult; }
        }
    }
}

window.controllers.searchFilterSelection = {
    dependencies: ["$element", "eventbus", "searchService"],
    callable: function(ele, eventBus, searchService) {

        init();

        function init() {
            var inputs = ele.querySelectorAll("input");
            for (var n = 0, e; e = inputs[n++];) {
                e.addEventListener('change', onInputChange);
            }
        }

        function onInputChange(evt) {
            evt.preventDefault();
            searchService.search(getFormValues());
        }

        function getFormValues() {
            var form = {};
            var inputs = ele.querySelectorAll("input");
            for (var n = 0, e; e = inputs[n++];) {
                if (e.name && e.value) {
                    form[e.name] = e.value;
                }
            }
            return form;
        }
    }
}

window.controllers.calenderPager = {
    dependencies: ["$element"],
    callable: function(ele) {
        ele.addEventListener('click', onClick);

        function onClick(evt) {
            var e = evt.target;
            if (e && e.nodeName.toLowerCase() == "a") {
                evt.preventDefault();
                var url = e.href;
                xhr.get(url).then(onNewCalendarFetched)
            }
        }

        function onNewCalendarFetched(xhr) {
            var e = document.createElement("div");
            e.innerHTML = xhr.responseText;
            var newCal = e.querySelector("[data-calendar]");
            var oldCal = ele.querySelector("[data-calendar]");
            oldCal.parentNode.replaceChild(newCal, oldCal);
        }
    }
}

window.controllers.togglableFilters = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        var toggleEle = ele.querySelector("[data-filter-toggler]");
        var filterEle = ele.querySelector("[data-filter-container]");
        toggleEle.addEventListener('click', toggle);

        function toggle() {
            filterEle.classList.toggle("u-hidden");
            eventBus.emit('filter-toggle');
        }
    }
}

window.controllers.resultList = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        eventBus.on('new-search-result', onSearchResult);
        function onSearchResult(result) {
            if (result && result.markup != null) {
                ele.innerHTML = result.markup;
            }
        }
    }
}

window.controllers.hitCount = {
    dependencies: ["$element", "eventbus"] ,
    callable: function(ele, eventBus) {
        eventBus.on('new-search-result', onSearchResult);
        function onSearchResult(result) {
            ele.innerHTML = "" + result.hits.length + " treff";
        }
    }
}

window.controllers.autoSizeTextArea = {
    callable: function(ele) {
        ele.addEventListener('change', adjustSize);
        ele.addEventListener('keyup', adjustSize);
        adjustSize();

        function adjustSize() {
            if (ele.scrollHeight > ele.offsetHeight) {
                ele.style.minHeight = (ele.scrollHeight + 44) + "px";
            }
        }
    }
}

window.controllers.submitMainForm = function(ele) {
    ele.addEventListener("click", function() {
        document.querySelector("[data-main-form]").submit();
    });
}
